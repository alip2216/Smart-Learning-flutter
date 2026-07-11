import 'package:flutter/material.dart';

class CustomAlert {
  /// Menampilkan dialog sukses bergaya SweetAlert
  static void showSuccess(BuildContext context, String title, {String? subtitle}) {
    _showDialog(
      context: context,
      icon: Icons.check_circle,
      iconColor: Colors.green,
      title: title,
      subtitle: subtitle,
    );
  }

  /// Menampilkan dialog error bergaya SweetAlert
  static void showError(BuildContext context, String title, {String? subtitle}) {
    _showDialog(
      context: context,
      icon: Icons.error,
      iconColor: Colors.redAccent,
      title: title,
      subtitle: subtitle,
    );
  }

  /// Menampilkan dialog warning bergaya SweetAlert
  static void showWarning(BuildContext context, String title, {String? subtitle}) {
    _showDialog(
      context: context,
      icon: Icons.warning_rounded,
      iconColor: Colors.orange,
      title: title,
      subtitle: subtitle,
    );
  }

  static void _showDialog({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => const SizedBox(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ),
          child: FadeTransition(
            opacity: animation,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              contentPadding: const EdgeInsets.all(24),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 80,
                    color: iconColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: iconColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'OK',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
