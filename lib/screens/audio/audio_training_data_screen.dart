import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../models/audio_training_models.dart';
import '../../services/audio_recording_storage_service.dart';
import '../../services/audio_sync_service.dart';
import '../../widgets/ayo_screen_background.dart';

class AudioTrainingDataScreen extends StatefulWidget {
  const AudioTrainingDataScreen({super.key});

  @override
  State<AudioTrainingDataScreen> createState() => _AudioTrainingDataScreenState();
}

class _AudioTrainingDataScreenState extends State<AudioTrainingDataScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AudioRecordingStorageService _storageService = AudioRecordingStorageService();
  final AudioSyncService _syncService = AudioSyncService();

  bool _isLoading = true;
  bool _isSyncing = false;
  String _selectedSpeakerFilter = 'ALL'; // ALL, TEACHER, STUDENT
  String _selectedLanguageFilter = 'ALL'; // ALL, HINDI, MUNDARI

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) setState(() {});
    });
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await _storageService.init();
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _triggerSync() async {
    setState(() => _isSyncing = true);
    final success = await _syncService.syncPendingAudio(isWifiConnected: true, isCharging: true);
    if (mounted) {
      setState(() => _isSyncing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'ऑडियो डेटा सफलता पूर्वक सिंक हुआ (Audio Synced)' : 'सिंक वाई-फाई/चार्जिंग की प्रतीक्षा में है (Sync Waiting)',
          ),
          backgroundColor: success ? const Color(0xFF2E7D32) : AppColors.primaryBurgundy,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
            'ऑडियो डेटा संग्रह (STT Training Data)',
            style: TextStyle(
              fontFamily: AppTypography.headingFontFamily,
              fontSize: 18.0,
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
                  : const Icon(Icons.cloud_upload_rounded, color: AppColors.primaryBurgundy, size: 26),
              tooltip: 'Sync Audio Now',
              onPressed: _isSyncing ? null : _triggerSync,
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // 3-Tab Header Switcher
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                  labelStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 12.0),
                  tabs: const [
                    Tab(text: 'सभी रिकॉर्डिंग'),
                    Tab(text: 'लंबित सिंक'),
                    Tab(text: 'स्टोरेज आँकड़े'),
                  ],
                ),
              ),

              const SizedBox(height: 8.0),

              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAllRecordingsTab(),
                    _buildPendingSyncTab(),
                    _buildStorageStatsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TAB 1: ALL RECORDINGS
  Widget _buildAllRecordingsTab() {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: AppColors.primaryBurgundy));

    var list = _storageService.recordings;
    if (_selectedSpeakerFilter == 'TEACHER') {
      list = list.where((e) => e.speakerType == AudioSpeakerTypeEnum.teacher).toList();
    } else if (_selectedSpeakerFilter == 'STUDENT') {
      list = list.where((e) => e.speakerType == AudioSpeakerTypeEnum.student).toList();
    }

    if (_selectedLanguageFilter == 'HINDI') {
      list = list.where((e) => e.language == AudioLanguagePairEnum.hindi).toList();
    } else if (_selectedLanguageFilter == 'MUNDARI') {
      list = list.where((e) => e.language == AudioLanguagePairEnum.mundari).toList();
    }

    return Column(
      children: [
        // Filter Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedSpeakerFilter,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'ALL', child: Text('सभी वक्ता (All Speakers)', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: 'TEACHER', child: Text('केवल शिक्षक', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: 'STUDENT', child: Text('केवल छात्र', style: TextStyle(fontSize: 12))),
                  ],
                  onChanged: (val) => setState(() => _selectedSpeakerFilter = val ?? 'ALL'),
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedLanguageFilter,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'ALL', child: Text('सभी भाषाएँ (All Languages)', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: 'HINDI', child: Text('हिंदी', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: 'MUNDARI', child: Text('मुंडारी', style: TextStyle(fontSize: 12))),
                  ],
                  onChanged: (val) => setState(() => _selectedLanguageFilter = val ?? 'ALL'),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8.0),

        // List
        Expanded(
          child: list.isEmpty
              ? const Center(child: Text('कोई ऑडियो रिकॉर्डिंग नहीं मिली।', style: TextStyle(fontFamily: 'Inter')))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return _AudioRecordingCard(
                      item: item,
                      onToggleApproval: (approved) async {
                        await _storageService.toggleApproval(item.id, approved);
                        setState(() {});
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  // TAB 2: PENDING SYNC
  Widget _buildPendingSyncTab() {
    final pending = _storageService.getPendingSyncRecordings();
    final totalSizeKb = pending.fold(0, (sum, e) => sum + e.fileSizeBytes) ~/ 1024;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: const Color(0xFFFDFBF7),
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: const Color(0xFFE8DECF)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${pending.length} रिकॉर्डिंग सिंक हेतु तैयार',
                      style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 15.0),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'कुल आकार: $totalSizeKb KB • केवल Wi-Fi + चार्जिंग',
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 12.0, color: Color(0xFF756760)),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: _isSyncing ? null : _triggerSync,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBurgundy,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                  ),
                  child: const Text('सिंक शुरू करें', style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16.0),

          Expanded(
            child: pending.isEmpty
                ? const Center(child: Text('सभी स्वीकृत ऑडियो रिकॉर्डिंग सिंक हो चुकी हैं!'))
                : ListView.builder(
                    itemCount: pending.length,
                    itemBuilder: (context, index) {
                      final item = pending[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                        child: ListTile(
                          leading: const Icon(Icons.mic_rounded, color: AppColors.primaryBurgundy),
                          title: Text(
                            item.transcriptionText ?? 'ध्वनि रिकॉर्डिंग',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 13.5),
                          ),
                          subtitle: Text(
                            'गुणवत्ता: ${(item.qualityScore * 100).toInt()}% • ${(item.fileSizeBytes / 1024).toStringAsFixed(1)} KB',
                            style: const TextStyle(fontSize: 11.5),
                          ),
                          trailing: const Icon(Icons.cloud_upload_outlined, color: Color(0xFFC88A22)),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // TAB 3: STORAGE STATS
  Widget _buildStorageStatsTab() {
    final usedBytes = _storageService.getTotalStorageUsedBytes();
    final usedMb = (usedBytes / (1024 * 1024)).toStringAsFixed(1);
    final hardMb = (AudioRecordingStorageService.hardQuotaBytes / (1024 * 1024)).toInt();
    final ratio = (usedBytes / AudioRecordingStorageService.hardQuotaBytes).clamp(0.0, 1.0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18.0),
            decoration: BoxDecoration(
              color: const Color(0xFFFDFBF7),
              borderRadius: BorderRadius.circular(18.0),
              border: Border.all(color: const Color(0xFFE8DECF)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('स्थानीय ऑडियो स्टोरेज कोटा (Local Storage Quota)', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 15.0)),
                const SizedBox(height: 12.0),
                LinearProgressIndicator(
                  value: ratio,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(5),
                  color: ratio > 0.8 ? Colors.redAccent : AppColors.primaryBurgundy,
                  backgroundColor: const Color(0xFFEFE8DA),
                ),
                const SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('उपयोग: $usedMb MB', style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600)),
                    Text('सीमा: $hardMb MB', style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Color(0xFF756760))),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20.0),

          const Text('ऑटो-सफाई व डिस्क प्रबंधन (Storage Cleanup)', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 15.0)),
          const SizedBox(height: 10.0),

          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
            child: ListTile(
              leading: const Icon(Icons.auto_delete_rounded, color: Color(0xFFC88A22)),
              title: const Text('30 दिन से पुरानी रिकॉर्डिंग हटाएँ', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 13.5)),
              subtitle: const Text('पुराने ऑडियो को हटाकर स्पेस खाली करें'),
              onTap: () async {
                final count = await _storageService.purgeRecordingsOlderThanDays(30);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$count पुरानी रिकॉर्डिंग हटाई गईं।')),
                  );
                  setState(() {});
                }
              },
            ),
          ),

          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
            child: ListTile(
              leading: const Icon(Icons.cleaning_services_rounded, color: Colors.redAccent),
              title: const Text('कम गुणवत्ता रिकॉर्डिंग (< 50%) साफ़ करें', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 13.5)),
              subtitle: const Text('शोर या बिना आवाज़ वाले ऑडियो डिलीट करें'),
              onTap: () async {
                final count = await _storageService.purgeLowQualityRecordings();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$count खराब रिकॉर्डिंग हटाई गईं।')),
                  );
                  setState(() {});
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AudioRecordingCard extends StatelessWidget {
  final AudioRecordingItem item;
  final ValueChanged<bool> onToggleApproval;

  const _AudioRecordingCard({
    required this.item,
    required this.onToggleApproval,
  });

  @override
  Widget build(BuildContext context) {
    final qualityPercent = (item.qualityScore * 100).toInt();
    final qualityColor = item.qualityScore >= 0.8
        ? const Color(0xFF2E7D32)
        : item.qualityScore >= 0.6
            ? const Color(0xFFC88A22)
            : const Color(0xFFC62828);

    final speakerBg = item.speakerType == AudioSpeakerTypeEnum.teacher ? const Color(0xFFF7EBEB) : const Color(0xFFFFF8E1);
    final speakerTextColor = item.speakerType == AudioSpeakerTypeEnum.teacher ? AppColors.primaryBurgundy : const Color(0xFFC88A22);

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFE8DECF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                decoration: BoxDecoration(color: speakerBg, borderRadius: BorderRadius.circular(8.0)),
                child: Text(
                  item.speakerType.toDisplayName(),
                  style: TextStyle(fontFamily: 'Inter', fontSize: 11.0, fontWeight: FontWeight.bold, color: speakerTextColor),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: qualityColor, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'गुणवत्ता: $qualityPercent%',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 11.5, fontWeight: FontWeight.bold, color: qualityColor),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Text(
            item.transcriptionText ?? 'ध्वनि रिकॉर्डिंग (No Transcript)',
            style: const TextStyle(fontFamily: 'Inter', fontSize: 14.0, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6.0),
          Text(
            'अवधि: ${item.durationSeconds.toStringAsFixed(1)}s • आकार: ${(item.fileSizeBytes / 1024).toStringAsFixed(1)} KB • Opus 12kbps',
            style: const TextStyle(fontFamily: 'Inter', fontSize: 11.5, color: Color(0xFF756760)),
          ),
          const SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.play_circle_fill_rounded, color: AppColors.primaryBurgundy, size: 30),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opus ऑडियो प्लेबैक चालू है...')),
                  );
                },
              ),
              Row(
                children: [
                  const Text('STT मॉडल ट्रेनिंग हेतु स्वीकृत:', style: TextStyle(fontFamily: 'Inter', fontSize: 12.0)),
                  Switch(
                    value: item.approvedForTraining,
                    activeTrackColor: const Color(0xFF2E7D32),
                    onChanged: onToggleApproval,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
