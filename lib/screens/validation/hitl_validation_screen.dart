import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../models/hitl_validation_models.dart';
import '../../services/hitl_sync_service.dart';
import '../../services/hitl_validation_service.dart';
import '../../widgets/ayo_screen_background.dart';
import '../../widgets/mundari_audio_text.dart';

class HitlValidationScreen extends StatefulWidget {
  const HitlValidationScreen({super.key});

  @override
  State<HitlValidationScreen> createState() => _HitlValidationScreenState();
}

class _HitlValidationScreenState extends State<HitlValidationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final HitlValidationService _validationService = HitlValidationService();
  final HitlSyncService _syncService = HitlSyncService();

  bool _isLoading = true;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) setState(() {});
    });
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await _validationService.init();
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _triggerSync() async {
    setState(() => _isSyncing = true);
    final success = await _syncService.syncPendingCorrections();
    if (mounted) {
      setState(() => _isSyncing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'सिंक संपन्न हुआ (Sync Successful)' : 'सिंक असफल या ऑफलाइन है (Offline / Sync Failed)',
          ),
          backgroundColor: success ? const Color(0xFF2E7D32) : AppColors.primaryBurgundy,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final activePair = _tabController.index == 0 ? LanguagePairEnum.hindiToMundari : LanguagePairEnum.mundariToHindi;
    final pendingItems = _validationService.getPendingByPair(activePair);
    final metadata = _validationService.metadata;

    return AyoScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left_rounded, size: 30, color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'शिक्षक सुधार केंद्र',
            style: TextStyle(
              fontFamily: AppTypography.headingFontFamily,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: _isSyncing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBurgundy),
                    )
                  : const Icon(Icons.sync_rounded, color: AppColors.primaryBurgundy, size: 26),
              tooltip: 'Sync Now',
              onPressed: _isSyncing ? null : _triggerSync,
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Sync Indicator Header
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDFBF7),
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: const Color(0xFFE8DECF)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            metadata.pendingSyncCount > 0 ? Icons.cloud_queue_rounded : Icons.cloud_done_rounded,
                            color: metadata.pendingSyncCount > 0 ? const Color(0xFFC88A22) : const Color(0xFF2E7D32),
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              metadata.pendingSyncCount > 0
                                  ? '${metadata.pendingSyncCount} लंबित सुधार (Pending Sync)'
                                  : 'सभी सुधार सिंक हैं (Synced)',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13.0,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: _isSyncing ? null : _triggerSync,
                      child: Text(
                        _isSyncing ? 'सिंक हो रहा है...' : 'सिंक करें',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBurgundy,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Language Pair Tabs
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFE8DA),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppColors.primaryBurgundy,
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textPrimary,
                  labelStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 13.5),
                  tabs: const [
                    Tab(text: 'हिंदी → मुंडारी'),
                    Tab(text: 'मुंडारी → हिंदी'),
                  ],
                ),
              ),

              const SizedBox(height: 12.0),

              // Flagged Cards List
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBurgundy))
                    : pendingItems.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_circle_outline_rounded, size: 64, color: Color(0xFF2E7D32)),
                                const SizedBox(height: 12),
                                Text(
                                  'कोई लंबित सत्यापन नहीं है!\n(All clear for ${activePair.toDisplayName()})',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 15.0,
                                    color: Color(0xFF756760),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            itemCount: pendingItems.length,
                            itemBuilder: (context, index) {
                              final item = pendingItems[index];
                              return _HitlCard(
                                item: item,
                                onAccept: () async {
                                  await _validationService.acceptTranslation(item.id);
                                  setState(() {});
                                },
                                onReject: () async {
                                  await _validationService.rejectTranslation(item.id);
                                  setState(() {});
                                },
                                onSaveEdit: (editedText) async {
                                  await _validationService.editAndSaveTranslation(
                                    flaggedId: item.id,
                                    editedText: editedText,
                                  );
                                  setState(() {});
                                },
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HitlCard extends StatefulWidget {
  final FlaggedTranslation item;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final ValueChanged<String> onSaveEdit;

  const _HitlCard({
    required this.item,
    required this.onAccept,
    required this.onReject,
    required this.onSaveEdit,
  });

  @override
  State<_HitlCard> createState() => _HitlCardState();
}

class _HitlCardState extends State<_HitlCard> {
  bool _isEditing = false;
  late TextEditingController _editController;

  @override
  void initState() {
    super.initState();
    _editController = TextEditingController(text: widget.item.targetText);
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final confPercent = (widget.item.confidence * 100).toInt();
    final confColor = widget.item.confidence >= 0.8
        ? const Color(0xFF2E7D32)
        : widget.item.confidence >= 0.6
            ? const Color(0xFFC88A22)
            : const Color(0xFFC62828);

    final confBg = widget.item.confidence >= 0.8
        ? const Color(0xFFE8F5E9)
        : widget.item.confidence >= 0.6
            ? const Color(0xFFFFF8E1)
            : const Color(0xFFFFEBEE);

    return Container(
      margin: const EdgeInsets.only(bottom: 14.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7),
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(color: const Color(0xFFE8DECF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Language Pair & Confidence Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.item.languagePair.toDisplayName(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBurgundy,
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: confBg,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  'विश्वास: $confPercent%',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: confColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),

          // Source Text
          const Text(
            'मूल शब्द/वाक्य (Source Text):',
            style: TextStyle(fontFamily: 'Inter', fontSize: 11.5, color: Color(0xFF8B7361)),
          ),
          const SizedBox(height: 2.0),
          widget.item.languagePair == LanguagePairEnum.mundariToHindi
              ? MundariAudioText(
                  text: widget.item.sourceText,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  mainAxisAlignment: MainAxisAlignment.start,
                )
              : Text(
                  widget.item.sourceText,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
          const SizedBox(height: 10.0),

          // AI Suggestion / Edit Box
          const Text(
            'मॉडल का अनुवाद (AI Suggestion):',
            style: TextStyle(fontFamily: 'Inter', fontSize: 11.5, color: Color(0xFF8B7361)),
          ),
          const SizedBox(height: 4.0),
          if (_isEditing)
            TextField(
              controller: _editController,
              autofocus: true,
              style: const TextStyle(fontFamily: 'Inter', fontSize: 15.0, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                filled: true,
                fillColor: Colors.white,
                hintText: 'सही अनुवाद लिखें (Enter Correction)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: Color(0xFFC88A22), width: 1.5),
                ),
              ),
            )
          else widget.item.languagePair == LanguagePairEnum.hindiToMundari
              ? MundariAudioText(
                  text: widget.item.targetText,
                  style: TextStyle(
                    fontFamily: AppTypography.headingFontFamily,
                    fontSize: 17.5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2E7D32),
                  ),
                  mainAxisAlignment: MainAxisAlignment.start,
                )
              : Text(
                  widget.item.targetText,
                  style: TextStyle(
                    fontFamily: AppTypography.headingFontFamily,
                    fontSize: 17.5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
          const SizedBox(height: 16.0),

          // Action Buttons: Wrap dynamically for small screens and landscape/portrait fit
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                if (_isEditing) ...[
                  TextButton(
                    onPressed: () => setState(() => _isEditing = false),
                    child: const Text('रद्द करें', style: TextStyle(color: Color(0xFF756760))),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final txt = _editController.text.trim();
                      if (txt.isNotEmpty) {
                        widget.onSaveEdit(txt);
                        setState(() => _isEditing = false);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC88A22),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    ),
                    child: const Text('सहेजें (Save)', style: TextStyle(color: Colors.white)),
                  ),
                ] else ...[
                  OutlinedButton(
                    onPressed: widget.onReject,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    ),
                    child: const Text('अस्वीकार', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
                  ),
                  OutlinedButton(
                    onPressed: () => setState(() => _isEditing = true),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFC88A22)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    ),
                    child: const Text('संशोधित करें', style: TextStyle(color: Color(0xFFC88A22), fontSize: 13)),
                  ),
                  ElevatedButton(
                    onPressed: widget.onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    ),
                    child: const Text('स्वीकार (Accept)', style: TextStyle(color: Colors.white, fontSize: 13)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
