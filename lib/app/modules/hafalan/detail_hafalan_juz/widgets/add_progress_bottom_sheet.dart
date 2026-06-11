import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/detail_hafalan_juz_controller.dart';

class AddProgressBottomSheet extends StatefulWidget {
  final int modeIndex;

  const AddProgressBottomSheet({
    super.key,
    required this.modeIndex,
  });

  @override
  State<AddProgressBottomSheet> createState() => _AddProgressBottomSheetState();
}

class _AddProgressBottomSheetState extends State<AddProgressBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _halamanMulaiC = TextEditingController();
  final _halamanSelesaiC = TextEditingController();
  final _catatanC = TextEditingController();

  String? _selectedKualitas;
  String? _selectedKeterangan;
  String? _errorMessage;

  @override
  void dispose() {
    _halamanMulaiC.dispose();
    _halamanSelesaiC.dispose();
    _catatanC.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = Get.find<DetailHafalanJuzController>();
    final am = int.tryParse(_halamanMulaiC.text);
    final as = int.tryParse(_halamanSelesaiC.text);

    if (am == null || as == null) return;

    if (am > as) {
      setState(
        () => _errorMessage =
            'Halaman mulai tidak boleh lebih besar dari halaman selesai',
      );
      return;
    }
    
    if (am < controller.firstHalaman || as > controller.lastHalaman) {
      setState(
        () => _errorMessage = 'Halaman harus di antara ${controller.firstHalaman} dan ${controller.lastHalaman}',
      );
      return;
    }

    if (widget.modeIndex == 0 && _selectedKualitas == null) {
      setState(() => _errorMessage = 'Silakan pilih kualitas');
      return;
    }
    if (_selectedKeterangan == null) {
      setState(() => _errorMessage = 'Silakan pilih keterangan');
      return;
    }

    setState(() => _errorMessage = null);

    await controller.saveSetoranByHalaman(
      int.parse(controller.santriId),
      int.parse(controller.juzId),
      am,
      as,
      widget.modeIndex == 0 ? _selectedKualitas : null,
      _selectedKeterangan!,
      _catatanC.text,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool isRequired = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: keyboardType == TextInputType.number
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: true,
        labelStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.deepPurpleAccent),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        isDense: true,
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: isRequired
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Harus diisi';
              }
              if (!value.isNumericOnly) {
                return 'Harus berupa angka';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildKualitasChips() {
    final options = ['Kurang', 'Cukup', 'Baik', 'Sangat Baik'];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = _selectedKualitas == option;
        Color bgColor;
        Color textColor;
        if (option == 'Kurang') {
          bgColor = isSelected ? Colors.red[50]! : Colors.grey[100]!;
          textColor = isSelected ? Colors.red[700]! : Colors.grey[700]!;
        } else if (option == 'Cukup') {
          bgColor = isSelected ? Colors.orange[50]! : Colors.grey[100]!;
          textColor = isSelected ? Colors.orange[700]! : Colors.grey[700]!;
        } else if (option == 'Baik') {
          bgColor = isSelected ? Colors.teal[50]! : Colors.grey[100]!;
          textColor = isSelected ? Colors.teal[700]! : Colors.grey[700]!;
        } else {
          bgColor = isSelected ? Colors.blue[50]! : Colors.grey[100]!;
          textColor = isSelected ? Colors.blue[700]! : Colors.grey[700]!;
        }

        return Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
          ),
          child: ChoiceChip(
            label: Text(option),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                setState(() {
                  _selectedKualitas = option;
                  _errorMessage = null;
                });
              }
            },
            selectedColor: bgColor,
            backgroundColor: Colors.grey[100],
            labelStyle: TextStyle(
              color: textColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected
                    ? textColor.withValues(alpha: 0.5)
                    : Colors.transparent,
              ),
            ),
            showCheckmark: false,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildKeteranganChips() {
    final options = ['Mengulang', 'Lanjut'];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = _selectedKeterangan == option;
        Color bgColor;
        Color textColor;
        if (option == 'Mengulang') {
          bgColor = isSelected ? Colors.orange[50]! : Colors.grey[100]!;
          textColor = isSelected ? Colors.orange[700]! : Colors.grey[700]!;
        } else {
          bgColor = isSelected ? Colors.green[50]! : Colors.grey[100]!;
          textColor = isSelected ? Colors.green[700]! : Colors.grey[700]!;
        }

        return Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
          ),
          child: ChoiceChip(
            label: Text(option),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                setState(() {
                  _selectedKeterangan = option;
                  _errorMessage = null;
                });
              }
            },
            selectedColor: bgColor,
            backgroundColor: Colors.grey[100],
            labelStyle: TextStyle(
              color: textColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected
                    ? textColor.withValues(alpha: 0.5)
                    : Colors.transparent,
              ),
            ),
            showCheckmark: false,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final labels = ['Hafalan', 'Murajaah', 'Tahsin'];
    final label = labels[widget.modeIndex];

    Color themeColor = Colors.deepPurpleAccent;
    final controller = Get.find<DetailHafalanJuzController>();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tambah Progres $label',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close, color: Colors.grey),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[100]!),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.blue,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.santriName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: 12,
                                  color: Colors.blueGrey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${DateTime.now().day} ${['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'][DateTime.now().month - 1]} ${DateTime.now().year}',
                                  style: TextStyle(
                                    color: Colors.blueGrey[600],
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.menu_book_rounded,
                                  size: 12,
                                  color: Colors.blueGrey[600],
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    'Juz ${controller.juzId}',
                                    style: TextStyle(
                                      color: Colors.blueGrey[600],
                                      fontSize: 11,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red[700],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _halamanMulaiC,
                        label: 'Halaman Mulai',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _halamanSelesaiC,
                        label: 'Halaman Selesai',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                if (widget.modeIndex == 0) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Kualitas',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildKualitasChips(),
                ],
                const SizedBox(height: 16),
                Text(
                  'Keterangan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                _buildKeteranganChips(),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _catatanC,
                  label: 'Catatan (Opsional)',
                  maxLines: 3,
                  isRequired: false,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: Obx(() {
                    final isLoading = controller.isSaveLoading.value;

                    return ElevatedButton(
                      onPressed: isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Simpan',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
