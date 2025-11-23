import 'package:flutter/material.dart';
import 'package:flutter_getx_app/models/appointment.dart';
import 'package:flutter_getx_app/models/appointment_models.dart';
import 'package:flutter_getx_app/theme/app_theme.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final AppointmentStatus status;
  final VoidCallback? onTap;
  final bool isCompact;

  const AppointmentCard({
    Key? key,
    required this.appointment,
    required this.status,
    this.onTap,
    this.isCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = _getStatusColors(status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: colors['background'],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: colors['border']!,
            width: 1,
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left colored tab
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: colors['tabColor'],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
              ),
              // Card content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(isCompact ? 6 : 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Time and Status Row
                      Row(
                        children: [
                          // Time
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: isCompact ? 10 : 12,
                                color: AppTheme.colorPalette['neutral']!['60']!,
                              ),
                              SizedBox(width: isCompact ? 2 : 4),
                              Text(
                                isCompact
                                    ? appointment.time
                                    : '${appointment.time} > ${_getEndTime(appointment.time)}',
                                style: TextStyle(
                                  fontSize: isCompact ? 10 : 12,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      AppTheme.colorPalette['neutral']!['60']!,
                                ),
                                overflow:
                                    isCompact ? TextOverflow.ellipsis : null,
                                maxLines: isCompact ? 1 : null,
                              ),
                            ],
                          ),

                          Spacer(flex: isCompact ? 2 : 1),

                          // Status Badge
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: isCompact ? 6 : 8,
                                vertical: isCompact ? 1 : 2),
                            decoration: BoxDecoration(
                              color: colors['badgeBackground'],
                              borderRadius:
                                  BorderRadius.circular(isCompact ? 8 : 12),
                            ),
                            child: Text(
                              _getStatusText(status),
                              style: TextStyle(
                                fontSize: isCompact ? 9 : 10,
                                fontWeight: FontWeight.w600,
                                color: colors['badgeText'],
                              ),
                            ),
                          ),
                        ],
                      ),

                      if (!isCompact) ...[
                        const SizedBox(height: 6),

                        // Patient Name
                        Text(
                          'Patient full name',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.colorPalette['neutral']!['90']!,
                          ),
                        ),

                        const SizedBox(height: 3),

                        // Follow-up text
                        Text(
                          'Follow-up',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.colorPalette['neutral']!['60']!,
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Action Buttons Row
                        Row(
                          children: [
                            // Chat Icon
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: AppTheme.colorPalette['neutral']!['10']!,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color:
                                      AppTheme.colorPalette['neutral']!['30']!,
                                ),
                              ),
                              child: Icon(
                                Icons.chat_bubble_outline,
                                size: 13,
                                color: AppTheme.colorPalette['neutral']!['60']!,
                              ),
                            ),

                            const SizedBox(width: 6),

                            // Phone Icon
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: AppTheme.colorPalette['neutral']!['10']!,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color:
                                      AppTheme.colorPalette['neutral']!['30']!,
                                ),
                              ),
                              child: Icon(
                                Icons.phone_outlined,
                                size: 13,
                                color: AppTheme.colorPalette['neutral']!['60']!,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, Color> _getStatusColors(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.done:
        return {
          'background': AppTheme.colorPalette['success']!['surface']!,
          'border': AppTheme.colorPalette['success']!['border']!,
          'badgeBackground': AppTheme.colorPalette['success']!['main']!,
          'badgeText': Colors.white,
          'tabColor': AppTheme.colorPalette['success']!['main']!,
        };
      case AppointmentStatus.notDone:
        return {
          'background': AppTheme.colorPalette['danger']!['surface']!,
          'border': AppTheme.colorPalette['danger']!['border']!,
          'badgeBackground': AppTheme.colorPalette['danger']!['main']!,
          'badgeText': Colors.white,
          'tabColor': AppTheme.colorPalette['danger']!['main']!,
        };
      case AppointmentStatus.cancelled:
        return {
          'background': AppTheme.colorPalette['danger']!['surface']!,
          'border': AppTheme.colorPalette['danger']!['border']!,
          'badgeBackground': AppTheme.colorPalette['danger']!['main']!,
          'badgeText': Colors.white,
          'tabColor': AppTheme.colorPalette['danger']!['main']!,
        };
      case AppointmentStatus.received:
        return {
          'background': const Color(0xFFFEF3C7), // Yellow surface
          'border': const Color(0xFFFCD34D), // Yellow border
          'badgeBackground': const Color(0xFFF59E0B), // Yellow main
          'badgeText': Colors.white,
          'tabColor': const Color(0xFFF59E0B), // Yellow main
        };
      default:
        return {
          'background': AppTheme.colorPalette['neutral']!['10']!,
          'border': AppTheme.colorPalette['neutral']!['30']!,
          'badgeBackground': AppTheme.colorPalette['neutral']!['60']!,
          'badgeText': Colors.white,
          'tabColor': AppTheme.colorPalette['neutral']!['60']!,
        };
    }
  }

  String _getStatusText(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.done:
        return 'Paid';
      case AppointmentStatus.notDone:
        return 'Urgent';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
      case AppointmentStatus.received:
        return 'Visit Finalized';
      default:
        return 'Unknown';
    }
  }

  String _getEndTime(String startTime) {
    // Parse the start time and add 30 minutes
    try {
      // Remove AM/PM and split
      final timeParts =
          startTime.replaceAll(RegExp(r'[AP]M'), '').trim().split(':');
      if (timeParts.length == 2) {
        int hour = int.parse(timeParts[0]);
        int minute = int.parse(timeParts[1]);

        // Add 30 minutes
        minute += 30;
        if (minute >= 60) {
          hour += 1;
          minute -= 60;
        }

        // Determine AM/PM
        String period = 'AM';
        if (hour >= 12) {
          period = 'PM';
          if (hour > 12) hour -= 12;
        }
        if (hour == 0) hour = 12;

        return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
      }
    } catch (e) {
      // Fallback if parsing fails
    }
    return '${startTime.split(' ')[0]}+30';
  }
}

// Special appointment cards for different statuses
class VisitFinalizedCard extends AppointmentCard {
  const VisitFinalizedCard({
    Key? key,
    required Appointment appointment,
    VoidCallback? onTap,
    bool isCompact = false,
  }) : super(
          key: key,
          appointment: appointment,
          status: AppointmentStatus.received,
          onTap: onTap,
          isCompact: isCompact,
        );
}

class UrgentCard extends AppointmentCard {
  const UrgentCard({
    Key? key,
    required Appointment appointment,
    VoidCallback? onTap,
    bool isCompact = false,
  }) : super(
          key: key,
          appointment: appointment,
          status: AppointmentStatus.notDone,
          onTap: onTap,
          isCompact: isCompact,
        );
}

class PaidCard extends AppointmentCard {
  const PaidCard({
    Key? key,
    required Appointment appointment,
    VoidCallback? onTap,
    bool isCompact = false,
  }) : super(
          key: key,
          appointment: appointment,
          status: AppointmentStatus.done,
          onTap: onTap,
          isCompact: isCompact,
        );
}

class CancelledCard extends AppointmentCard {
  const CancelledCard({
    Key? key,
    required Appointment appointment,
    VoidCallback? onTap,
    bool isCompact = false,
  }) : super(
          key: key,
          appointment: appointment,
          status: AppointmentStatus.cancelled,
          onTap: onTap,
          isCompact: isCompact,
        );
}
