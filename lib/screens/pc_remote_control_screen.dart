import 'package:flutter/material.dart';
import 'package:remotesync/widgets/appBar.dart';
import '../services/remote_api_services.dart';
import '../widgets/remote_button.dart';
import '../widgets/large_utility_button.dart';
import '../widgets/section_container.dart';
import '../theme/app_colors.dart';
import '../theme/responsive_helper.dart';

class PCRemoteControlScreen extends StatelessWidget {
  const PCRemoteControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final padding = ResponsiveHelper.getPadding(width);

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: padding,
                  right: padding,
                  top: padding,
                  bottom: padding * 2,
                ),
                child: Column(
                  children: [
                    _buildSystemPowerSection(width),
                    SizedBox(height: padding),
                    _buildMediaSection(width),
                    SizedBox(height: padding),
                    _buildUtilitiesSection(width),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSystemPowerSection(double width) {
    final columns = ResponsiveHelper.getSystemPowerColumns(width);
    final spacing = ResponsiveHelper.getSpacing(width);

    return SectionContainer(
      title: 'SYSTEM POWER',
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: columns,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          RemoteButton(
            icon: Icons.lock,
            label: 'Lock',
            backgroundColor: AppColors.standardButton,
            onPressed: () => RemoteApiService.systemControl('lock'),
          ),
          RemoteButton(
            icon: Icons.circle,
            label: 'Sleep',
            backgroundColor: AppColors.standardButton,
            onPressed: () => RemoteApiService.systemControl('sleep'),
          ),
          RemoteButton(
            icon: Icons.refresh,
            label: 'Reboot',
            backgroundColor: AppColors.criticalButton,
            onPressed: () => RemoteApiService.systemControl('reboot'),
          ),
          RemoteButton(
            icon: Icons.power_settings_new,
            label: 'Shutdown',
            backgroundColor: AppColors.criticalButton,
            onPressed: () => RemoteApiService.systemControl('shutdown'),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaSection(double width) {
    final columns = ResponsiveHelper.getMediaColumns(width);
    final spacing = ResponsiveHelper.getSpacing(width);

    return SectionContainer(
      title: 'MEDIA',
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: columns,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          RemoteButton(
            icon: Icons.volume_up,
            label: 'Vol Up',
            backgroundColor: AppColors.standardButton,
            onPressed: () => RemoteApiService.mediaControl('volumeup'),
          ),
          RemoteButton(
            icon: Icons.skip_previous,
            label: 'Previous',
            backgroundColor: AppColors.standardButton,
            onPressed: () => RemoteApiService.mediaControl('prevtrack'),
          ),
          RemoteButton(
            icon: Icons.play_arrow,
            label: 'Play/Pause',
            backgroundColor: AppColors.standardButton,
            onPressed: () => RemoteApiService.mediaControl('playpause'),
          ),
          RemoteButton(
            icon: Icons.skip_next,
            label: 'Next',
            backgroundColor: AppColors.standardButton,
            onPressed: () => RemoteApiService.mediaControl('nexttrack'),
          ),
          RemoteButton(
            icon: Icons.volume_down,
            label: 'Vol Down',
            backgroundColor: AppColors.standardButton,
            onPressed: () => RemoteApiService.mediaControl('volumedown'),
          ),
          RemoteButton(
            icon: Icons.volume_off,
            label: 'Mute',
            backgroundColor: AppColors.standardButton,
            onPressed: () => RemoteApiService.mediaControl('volumemute'),
          ),
        ],
      ),
    );
  }

  Widget _buildUtilitiesSection(double width) {
    final spacing = ResponsiveHelper.getSpacing(width);
    final buttonHeight = ResponsiveHelper.getUtilityButtonHeight(width);  // NEW

    return SectionContainer(
      title: 'UTILITIES',
      child: Row(
        children: [
          LargeUtilityButton(
            icon: Icons.language,
            label: 'Browser',
            backgroundColor: AppColors.standardButton,
            height: buttonHeight,  // NEW: Pass responsive height
            onPressed: () => RemoteApiService.openBrowser(),
          ),
          SizedBox(width: spacing),
          LargeUtilityButton(
            icon: Icons.camera_alt,
            label: 'Screenshot',
            backgroundColor: AppColors.standardButton,
            height: buttonHeight,  // NEW: Pass responsive height
            onPressed: () => RemoteApiService.takeScreenshot(),
          ),
        ],
      ),
    );
  }

}
