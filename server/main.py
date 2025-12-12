import os
import sys
import uvicorn
import socket
import pyautogui
import webbrowser
from zeroconf import ServiceInfo, Zeroconf
from fastapi import FastAPI, HTTPException
from fastapi.responses import HTMLResponse, FileResponse
from pathlib import Path
import mss
from datetime import datetime
from dotenv import load_dotenv
from datetime import datetime

# sys.stdin.reconfigure(encoding='utf-8', errors='replace')
# sys.stdout.reconfigure(encoding='utf-8', errors='replace')
# sys.stderr.reconfigure(encoding='utf-8', errors='replace')

def resource_path(relative_path):
    try:
        base_path = sys._MEIPASS
    except Exception:   
        base_path = os.path.abspath(".")
    return os.path.join(base_path, relative_path)


load_dotenv()


screenshots_dir = Path("screenshots")
screenshots_dir.mkdir(exist_ok=True)


app = FastAPI()


@app.get("/verify")
def verify_connection():
    return {
        "status": "ok",
        "timestamp": datetime.now().isoformat(),
        "host": LOCAL_IP,
        "port": PORT
    }

def get_local_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.connect(('10.255.255.255', 1))
        IP = s.getsockname()[0]
    except Exception:
        IP = '127.0.0.1'
    finally:
        s.close()
    return IP


HOST = os.getenv("HOST", "0.0.0.0")
PORT = int(os.getenv("PORT", 8000))
LOCAL_IP = get_local_ip()


@app.get("/", response_class=HTMLResponse)
async def get_remote_control_page():
    html_path = resource_path("index.html")
    html_content = Path(html_path).read_text()
    api_url = f"http://{LOCAL_IP}:{PORT}"
    modified_html = html_content.replace("{{API_BASE_URL}}", api_url)
    return HTMLResponse(content=modified_html)


@app.post("/system/{action}")
def system_power_control(action: str):
    try:
        if action == "shutdown":
            if os.name == 'nt': os.system('shutdown /s /t 1')
            else: os.system('shutdown now')
            message = "Shutdown command issued."
        elif action == "reboot":
            if os.name == 'nt': os.system('shutdown /r /t 1')
            else: os.system('reboot')
            message = "Reboot command issued."
        elif action == "sleep":
            if os.name == 'nt': os.system('rundll32.exe powrprof.dll,SetSuspendState 0,1,0')
            elif os.name == 'posix': os.system('pmset sleepnow')
            else: os.system('systemctl suspend')
            message = "Sleep command issued."
        elif action == "lock":
            if os.name == 'nt': os.system('rundll32.exe user32.dll,LockWorkStation')
            elif os.name == 'posix': os.system('pmset displaysleepnow')
            else: os.system('xdg-screensaver lock')
            message = "Lock command issued."
        else:
            raise HTTPException(status_code=400, detail="Invalid system action")
        
        return {"message": message}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/media/{action}")
def media_control(action: str):
    valid_actions = ["playpause", "nexttrack", "prevtrack", "volumeup", "volumedown", "volumemute"]
    if action not in valid_actions:
        raise HTTPException(status_code=400, detail="Invalid media action")
    try:
        pyautogui.press(action)
        return {"message": f"Media command '{action}' issued."}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/action/screenshot", response_class=FileResponse)
def get_screenshot():
    try:
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")

        filepath = screenshots_dir / f"screenshot_{timestamp}.png"
        with mss.mss() as sct:
            sct.shot(output=str(filepath))
        return FileResponse(path=filepath, media_type='image/png', filename=filepath.name)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/app/browser")
def open_browser():
    try:
        webbrowser.open("https://google.com")
        return {"message": "Browser opened."}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


if __name__ == "__main__":
    def is_port_available(host, port):
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        try:
            sock.bind((host, port))
            sock.close()
            return True
        except:
            return False

    def find_free_port(start_port):
        port = start_port
        while port < 65535:
            if is_port_available("127.0.0.1", port):
                return port
            port += 1
        raise RuntimeError("No free ports available")

    # HOST priority: .env → 0.0.0.0 → LOCAL_IP → 127.0.0.1
    host_candidates = [
        HOST,               # from .env
        "0.0.0.0",
        LOCAL_IP,
        "127.0.0.1",
    ]

    port = PORT
    if not is_port_available("0.0.0.0", port):
        port = find_free_port(port)

    final_host = None
    for h in host_candidates:
        try:
            test_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            test_sock.bind((h, port))
            test_sock.close()
            final_host = h
            break
        except:
            continue

    if final_host is None:
        raise RuntimeError("Unable to bind to any fallback hosts")

    print("------------------------------------------------")
    print("PC Remote API is running!")
    print(f"Host: {final_host}")
    print(f"Port: {port}")
    print(f"Open this URL on your phone:")
    print(f"   http://{LOCAL_IP}:{PORT}")
    print("------------------------------------------------")

    uvicorn.run(app, host=final_host, port=port)
