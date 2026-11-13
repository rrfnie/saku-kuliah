import 'package:flutter/material.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/pastel_button.dart';
import '../../../../core/widgets/pastel_card.dart';
import '../../../../core/widgets/status_badge.dart';

/// Modal Simulasi & Kalkulator IPK Interaktif
class IpkSimulatorSheet extends StatefulWidget {
  final VoidCallback? onApplied;

  const IpkSimulatorSheet({super.key, this.onApplied});

  static Future<void> show(BuildContext context, {VoidCallback? onApplied}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => IpkSimulatorSheet(onApplied: onApplied),
    );
  }

  @override
  State<IpkSimulatorSheet> createState() => _IpkSimulatorSheetState();
}

class _IpkSimulatorSheetState extends State<IpkSimulatorSheet> {
  late List<Map<String, dynamic>> _simCourses;

  @override
  void initState() {
    super.initState();
    final realCourses = SakuKuliahState.instance.krsCourses;
    _simCourses = realCourses.map((c) => {
      'id': c.id,
      'name': c.courseName,
      'sks': c.sks,
      'grade': c.targetGrade,
      'point': c.gradePoint,
    }).toList();
  }

  final Map<String, double> _gradePoints = {
    'A': 4.00,
    'A-': 3.70,
    'B+': 3.30,
    'B': 3.00,
    'B-': 2.70,
    'C+': 2.30,
    'C': 2.00,
    'D': 1.00,
    'E': 0.00,
  };

  // Base cumulative stats before this semester (Dinamis dari riwayat semester lalu)
  double get _previousCumulativeIpk => SakuKuliahState.instance.studentProfile.cumulativeIpk;
  int get _previousCompletedSks => SakuKuliahState.instance.studentProfile.completedSks;

  double get _simulatedIps {
    double totalPoints = 0;
    int totalSks = 0;
    for (final c in _simCourses) {
      final sks = c['sks'] as int;
      final point = c['point'] as double;
      totalPoints += (point * sks);
      totalSks += sks;
    }
    return totalSks == 0 ? 0.0 : totalPoints / totalSks;
  }

  double get _simulatedCumulativeIpk {
    final newSks = _simCourses.fold<int>(0, (sum, c) => sum + (c['sks'] as int));
    final double prevTotalScore = _previousCumulativeIpk * _previousCompletedSks;
    final double newTotalScore = _simulatedIps * newSks;
    final totalSks = _previousCompletedSks + newSks;
    return totalSks == 0 ? 0.0 : (prevTotalScore + newTotalScore) / totalSks;
  }

  @override
  Widget build(BuildContext context) {
    final ips = _simulatedIps;
    final ipk = _simulatedCumulativeIpk;
    final isCumlaude = ipk >= 3.50;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Grab Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
            ),
            const SizedBox(height: 14),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calculate_rounded, color: AppColors.primary, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Simulasi & Kalkulator IPK',
                      style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Ubah target nilai tiap matkul di bawah ini untuk melihat hasil simulasi secara instan.',
              style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 14),

            // Live Simulation Summary Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppColors.primaryFixed,
                    AppColors.secondaryContainer,
                    AppColors.surfaceContainerHigh,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('PREDIKSI IP SEMESTER', style: AppTypography.labelSm),
                          const SizedBox(height: 2),
                          Text(
                            ips.toStringAsFixed(2),
                            style: AppTypography.displayLg.copyWith(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('PREDIKSI IPK KUMULATIF', style: AppTypography.labelSm),
                          const SizedBox(height: 2),
                          Text(
                            ipk.toStringAsFixed(2),
                            style: AppTypography.displayLg.copyWith(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (isCumlaude)
                    StatusBadge.cumlaude(label: 'Predikat: Dengan Pujian (Cumlaude) 🌸'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Builder(
              builder: (context) {
                final totalSimSks = _simCourses.fold<int>(0, (sum, c) => sum + (c['sks'] as int));
                return Text(
                  'Ubah Target Nilai Mata Kuliah ($totalSimSks SKS)',
                  style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold),
                );
              },
            ),
            const SizedBox(height: 8),

            if (_simCourses.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.school_outlined, size: 40, color: AppColors.onSurfaceVariant),
                      const SizedBox(height: 8),
                      Text(
                        'Belum ada mata kuliah KRS aktif 🌸',
                        style: AppTypography.headlineSm.copyWith(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tambahkan mata kuliah di halaman Akademik atau scan KRS untuk mulai simulasi nilai.',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodySm.copyWith(
                          fontSize: 11,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              // Course Simulation Sliders/Selectors
              ...List.generate(_simCourses.length, (index) {
                final course = _simCourses[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: PastelCard(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                course['name'] as String,
                                style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${course['sks']} SKS',
                                style: AppTypography.bodySm.copyWith(
                                  fontSize: 11,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0x33F4DCE4)),
                          ),
                          child: DropdownButton<String>(
                            value: course['grade'] as String,
                            underline: const SizedBox(),
                            items: _gradePoints.keys.map((grade) {
                              return DropdownMenuItem(
                                value: grade,
                                child: Text(
                                  '$grade (${_gradePoints[grade]!.toStringAsFixed(1)})',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  course['grade'] = val;
                                  course['point'] = _gradePoints[val]!;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 16),

              // Action Button
              PastelButton(
                text: 'Terapkan ke Target Semester',
                width: double.infinity,
                onPressed: () {
                  final state = SakuKuliahState.instance;
                  for (final sim in _simCourses) {
                    final id = sim['id'] as int?;
                    if (id != null) {
                      state.updateKrsGrade(
                        id,
                        sim['grade'] as String,
                        sim['point'] as double,
                      );
                    }
                  }
                  Navigator.pop(context);
                  widget.onApplied?.call();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Target nilai berhasil disimulasikan & disimpan lokal! 🌸')),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

