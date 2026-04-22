import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../providers/language_provider.dart';

class LanguageSelectorScreen extends StatefulWidget {
  const LanguageSelectorScreen({Key? key}) : super(key: key);

  @override
  State<LanguageSelectorScreen> createState() => _LanguageSelectorScreenState();
}

class _LanguageSelectorScreenState extends State<LanguageSelectorScreen> {
  late String _selectedCode;

  @override
  void initState() {
    super.initState();
    _selectedCode = context.read<LanguageProvider>().currentLanguage;
  }

  TextStyle _labelStyle(String code) {
    switch (code) {
      case 'am':
        return GoogleFonts.notoSansEthiopic(fontSize: 15);
      case 'ar':
        return GoogleFonts.notoSansArabic(fontSize: 15);
      case 'hi':
        return GoogleFonts.notoSansDevanagari(fontSize: 15);
      case 'zh':
        return GoogleFonts.notoSansSc(fontSize: 15);
      default:
        return GoogleFonts.poppins(fontSize: 15);
    }
  }

  Future<void> _apply() async {
    await context.read<LanguageProvider>().changeLanguage(_selectedCode);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = _selectedCode == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Select Language',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 18.0,
              color: isDark ? Colors.white : AppColors.lightTextPrimary,
            ),
          ),
          leading: IconButton(
            icon: Icon(
              isArabic ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
              color: isDark ? Colors.white : AppColors.lightTextPrimary,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingM,
                  vertical: AppSizes.paddingS,
                ),
                itemCount: LanguageProvider.supportedLanguages.length,
                separatorBuilder: (_, __) => Divider(
                  color: isDark
                      ? Colors.white12
                      : AppColors.lightTextSecondary.withValues(alpha: 0.15),
                  height: 1,
                ),
                itemBuilder: (context, index) {
                  final lang = LanguageProvider.supportedLanguages[index];

                  return InkWell(
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    onTap: () => setState(() => _selectedCode = lang.code),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingS,
                        vertical: AppSizes.paddingM,
                      ),
                      child: Row(
                        children: [
                          Text(
                            lang.flag,
                            style: const TextStyle(fontSize: 28),
                          ),
                          const SizedBox(width: AppSizes.spacingM),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lang.nativeName,
                                  style: _labelStyle(lang.code).copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.lightTextPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  lang.englishName,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.white54
                                        : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Radio<String>(
                            value: lang.code,
                            groupValue: _selectedCode,
                            activeColor: AppColors.primary,
                            onChanged: (v) =>
                                setState(() => _selectedCode = v!),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: SizedBox(
                width: double.infinity,
                height: AppSizes.buttonHeightM,
                child: ElevatedButton(
                  onPressed: _apply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                  ),
                  child: Text(
                    'Apply',
                    style: GoogleFonts.poppins(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
