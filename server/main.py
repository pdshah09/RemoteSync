import os
import uvicorn
import socket
import pyautogui
import webbrowser
from fastapi import FastAPI, HTTPException
from fastapi.responses import HTMLResponse, FileResponse
from pathlib import Path
import mss
from datetime import datetime
from dotenv import load_dotenv

# --- Load environment variables from .env file ---
load_dotenv()

# --- Create a directory for screenshots if it doesn't exist ---
Path("screenshots").mkdir(exist_ok=True)

app = FastAPI()

# --- Helper Function to get the local IP address ---
def get_local_ip():
    """Finds the local IP address of the machine."""
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.connect(('10.255.255.255', 1))
        IP = s.getsockname()[0]
    except Exception:
        IP = '127.0.0.1' # Fallback to localhost
    finally:
        s.close()
    return IP

# --- Get host and port from environment variables ---
HOST = os.getenv("HOST", "0.0.0.0")
PORT = int(os.getenv("PORT", 8000))
LOCAL_IP = get_local_ip()

# --- Root endpoint now serves the HTML UI ---
@app.get("/", response_class=HTMLResponse)
async def get_remote_control_page():
    """ Serves the index.html file with the dynamic IP address. """
    html_content = Path("index.html").read_text()
    api_url = f"http://{LOCAL_IP}:{PORT}"
    modified_html = html_content.replace("{{API_BASE_URL}}", api_url)
    return HTMLResponse(content=modified_html)

# === API Endpoints ===

# --- Group: System Power Controls ---
@app.post("/system/{action}")
def system_power_control(action: str):
    """ Handles shutdown, reboot, sleep, and lock actions. """
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

# --- Group: Media Controls ---
@app.post("/media/{action}")
def media_control(action: str):
    """ Handles media key presses using pyautogui. """
    valid_actions = ["playpause", "nexttrack", "prevtrack", "volumeup", "volumedown", "volumemute"]
    if action not in valid_actions:
        raise HTTPException(status_code=400, detail="Invalid media action")
    try:
        pyautogui.press(action)
        return {"message": f"Media command '{action}' issued."}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# --- Group: Application & Utility Controls ---
@app.get("/action/screenshot", response_class=FileResponse)
def get_screenshot():
    """ Takes a screenshot and returns it as an image file. """
    try:
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filepath = Path(f"screenshots/screenshot_{timestamp}.png")
        with mss.mss() as sct:
            sct.shot(output=str(filepath))
        return FileResponse(path=filepath, media_type='image/png', filename=filepath.name)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/app/browser")
def open_browser():
    """ Opens the default web browser. """
    try:
        webbrowser.open("https://google.com")
        return {"message": "Browser opened."}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# --- Main execution block ---
if __name__ == "__main__":
    print("─" * 40)
    print("✅ PC Remote API is running!")
    print(f"   Open this URL on your phone's browser:")
    print(f"   http://{LOCAL_IP}:{PORT}")
    print("─" * 40)
    uvicorn.run(app, host=HOST, port=PORT)
