import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';

class CustomAnimationSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final String hintText;
  final String centerTitle;
  final TextInputType keyboardType;
  final Color? cursorColor;
  final IconData? backIcon;
  final int? minValue;
  final int? maxValue;
  final String? minValueErrorMessage;
  final String? maxValueErrorMessage;
  final bool showSearchIcon;

  const CustomAnimationSearchBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.onSubmitted,
    this.hintText = 'Search...',
    this.centerTitle = 'Title',
    this.keyboardType = TextInputType.text,
    this.cursorColor,
    this.backIcon,
    this.minValue,
    this.maxValue,
    this.minValueErrorMessage,
    this.maxValueErrorMessage,
    this.showSearchIcon = true,
  });

  @override
  State<CustomAnimationSearchBar> createState() =>
      _CustomAnimationSearchBarState();
}

class _CustomAnimationSearchBarState extends State<CustomAnimationSearchBar> {
  bool _isSearching = false;
  DateTime? _lastToastTime;

  void _showThrottledToast(String message) {
    final now = DateTime.now();
    if (_lastToastTime != null &&
        now.difference(_lastToastTime!).inMilliseconds < 2000) {
      return;
    }
    _lastToastTime = now;
    ToastUtils.showErrorToast(message);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SizedBox(
        height: kToolbarHeight,
        child: Row(
          children: [
            // Back Button / Search Toggle
            IconButton(
              icon: Icon(
                _isSearching
                    ? Icons.close
                    : widget.backIcon ?? Icons.arrow_back,
              ),
              onPressed: () {
                setState(() {
                  if (_isSearching) {
                    widget.controller.clear();
                    _isSearching = !_isSearching;
                  } else {
                    Get.back();
                  }
                });
              },
            ),

            // Animated Title / Search Field
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _isSearching
                    ? TextField(
                        key: const ValueKey('searchField'),
                        controller: widget.controller,
                        autofocus: true,
                        keyboardType: widget.keyboardType,
                        textInputAction: widget.onSubmitted != null
                            ? TextInputAction.done
                            : null,
                        cursorColor: widget.cursorColor ?? Colors.deepPurple,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          hintText: widget.hintText,
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.deepPurple.shade200,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                        ),
                        onChanged: widget.onSubmitted != null
                            ? null
                            : (text) {
                                if (text.isEmpty) return;
                                final val = int.tryParse(text);
                                final max = widget.maxValue;
                                if (val == null || val < 1) {
                                  _showThrottledToast(
                                    'Masukkan angka yang valid!',
                                  );
                                  widget.controller.clear();
                                  return;
                                }
                                if (max != null && val > max) {
                                  _showThrottledToast(
                                    widget.maxValueErrorMessage ??
                                        'Melebihi jumlah ayat (maks. $max)',
                                  );
                                  widget.controller.clear();
                                  return;
                                }
                                widget.onChanged?.call(text);
                              },
                        onSubmitted: widget.onSubmitted != null
                            ? (text) {
                                if (text.isEmpty) return;
                                final val = int.tryParse(text);
                                if (val == null || val < 1) {
                                  _showThrottledToast(
                                    'Masukkan angka yang valid!',
                                  );
                                  widget.controller.clear();
                                  return;
                                }
                                final min = widget.minValue;
                                if (min != null && val < min) {
                                  _showThrottledToast(
                                    widget.minValueErrorMessage ??
                                        'Nilai minimum adalah $min',
                                  );
                                  widget.controller.clear();
                                  return;
                                }
                                final max = widget.maxValue;
                                if (max != null && val > max) {
                                  _showThrottledToast(
                                    widget.maxValueErrorMessage ??
                                        'Melebihi batas (maks. $max)',
                                  );
                                  widget.controller.clear();
                                  return;
                                }
                                widget.onSubmitted?.call(text);
                              }
                            : null,
                      )
                    : Center(
                        child: Text(
                          widget.centerTitle,
                          key: const ValueKey('titleText'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
            ),

            // Search Icon / Balancing space
            if (!_isSearching)
              widget.showSearchIcon
                  ? IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () => setState(() => _isSearching = true),
                    )
                  : const SizedBox(
                      width: 48,
                    ), // Lebar standar IconButton untuk menyeimbangkan layout
          ],
        ),
      ),
    );
  }
}
