import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';

class LoadingOverlay extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black26,
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFE9F24),
        ),
      ),
    );
  }
}
