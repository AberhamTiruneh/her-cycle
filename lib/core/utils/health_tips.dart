import 'package:flutter/material.dart';

// ─── HealthTip model ────────────────────────────────────────────────────────

class HealthTip {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String category; // nutrition, exercise, self_care, medical

  const HealthTip({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.category,
  });
}

// ─── HealthTips engine ──────────────────────────────────────────────────────

class HealthTips {
  HealthTips._();

  // Tips keyed by symptom name (case-insensitive match)
  static const Map<String, List<HealthTip>> _symptomTips = {
    'Cramps': [
      HealthTip(
        title: 'Heat therapy',
        description:
            'A heating pad or warm water bottle on your lower abdomen relaxes uterine muscles and eases cramping within minutes.',
        icon: Icons.whatshot_rounded,
        color: Color(0xFFEF5350),
        category: 'self_care',
      ),
      HealthTip(
        title: 'Magnesium-rich foods',
        description:
            'Dark chocolate, almonds, and leafy greens are high in magnesium, which helps relax muscles and reduce period pain.',
        icon: Icons.restaurant_rounded,
        color: Color(0xFF66BB6A),
        category: 'nutrition',
      ),
    ],
    'Bloating': [
      HealthTip(
        title: 'Reduce salt & processed foods',
        description:
            'Cutting back on sodium in the days before your period helps prevent water retention and bloating.',
        icon: Icons.no_food_rounded,
        color: Color(0xFFFFA726),
        category: 'nutrition',
      ),
      HealthTip(
        title: 'Peppermint or ginger tea',
        description:
            'Herbal teas with peppermint or ginger aid digestion and can quickly relieve abdominal bloating.',
        icon: Icons.local_cafe_rounded,
        color: Color(0xFF26A69A),
        category: 'nutrition',
      ),
    ],
    'Fatigue': [
      HealthTip(
        title: 'Boost iron intake',
        description:
            'Spinach, lentils, and lean red meat replenish iron lost during menstruation and help combat fatigue.',
        icon: Icons.restaurant_rounded,
        color: Color(0xFF66BB6A),
        category: 'nutrition',
      ),
      HealthTip(
        title: 'Prioritize sleep',
        description:
            'Aim for 7–9 hours during your period. A consistent sleep schedule restores energy better than sleeping in.',
        icon: Icons.bedtime_rounded,
        color: Color(0xFF5C6BC0),
        category: 'self_care',
      ),
    ],
    'Headache': [
      HealthTip(
        title: 'Stay hydrated',
        description:
            'Even mild dehydration can trigger menstrual headaches. Aim for 8 glasses of water daily and limit caffeine.',
        icon: Icons.water_drop_rounded,
        color: Color(0xFF29B6F6),
        category: 'self_care',
      ),
      HealthTip(
        title: 'Magnesium supplement',
        description:
            'Studies show daily magnesium (200–400 mg) can reduce frequency and severity of menstrual migraines.',
        icon: Icons.medication_rounded,
        color: Color(0xFFAB47BC),
        category: 'medical',
      ),
    ],
    'Mood Swings': [
      HealthTip(
        title: 'Move your body',
        description:
            'Even a 20-minute walk triggers endorphin release, which helps stabilize mood during hormonal fluctuations.',
        icon: Icons.directions_walk_rounded,
        color: Color(0xFF42A5F5),
        category: 'exercise',
      ),
      HealthTip(
        title: 'Omega-3 fatty acids',
        description:
            'Salmon, walnuts, and flaxseed are rich in omega-3s, which research links to improved mood and reduced PMS symptoms.',
        icon: Icons.restaurant_rounded,
        color: Color(0xFF66BB6A),
        category: 'nutrition',
      ),
    ],
    'Breast Tenderness': [
      HealthTip(
        title: 'Reduce caffeine',
        description:
            'Caffeine can increase breast tissue sensitivity. Switching to herbal tea in the week before your period may help.',
        icon: Icons.no_drinks_rounded,
        color: Color(0xFFFFA726),
        category: 'nutrition',
      ),
      HealthTip(
        title: 'Supportive bra',
        description:
            'Wearing a well-fitted, supportive bra (including at night if needed) reduces movement and relieves tenderness.',
        icon: Icons.accessibility_new_rounded,
        color: Color(0xFFE91E8C),
        category: 'self_care',
      ),
    ],
    'Acne': [
      HealthTip(
        title: 'Zinc-rich foods',
        description:
            'Pumpkin seeds, chickpeas, and cashews are high in zinc, which helps regulate oil production and hormonal acne.',
        icon: Icons.restaurant_rounded,
        color: Color(0xFF66BB6A),
        category: 'nutrition',
      ),
      HealthTip(
        title: 'Gentle cleansing routine',
        description:
            'Wash your face twice daily with a gentle, non-comedogenic cleanser. Avoid touching your face to prevent spreading bacteria.',
        icon: Icons.face_retouching_natural_rounded,
        color: Color(0xFFF06292),
        category: 'self_care',
      ),
    ],
    'Back Pain': [
      HealthTip(
        title: 'Gentle stretching',
        description:
            "Child's pose, cat-cow stretches, and gentle yoga specifically targeting the lower back can provide quick relief.",
        icon: Icons.self_improvement_rounded,
        color: Color(0xFF26A69A),
        category: 'exercise',
      ),
      HealthTip(
        title: 'Warm bath',
        description:
            'Soaking in a warm bath for 15–20 minutes relaxes back muscles and eases cramping-related back pain.',
        icon: Icons.bathtub_rounded,
        color: Color(0xFF5C6BC0),
        category: 'self_care',
      ),
    ],
    'Nausea': [
      HealthTip(
        title: 'Ginger remedy',
        description:
            'Ginger tea, ginger chews, or ginger capsules are clinically shown to reduce nausea. Sip slowly on an empty stomach.',
        icon: Icons.local_cafe_rounded,
        color: Color(0xFF26A69A),
        category: 'nutrition',
      ),
      HealthTip(
        title: 'Small, frequent meals',
        description:
            'Eating small portions every 2–3 hours prevents an empty stomach, which worsens nausea. Avoid greasy or spicy foods.',
        icon: Icons.restaurant_rounded,
        color: Color(0xFF66BB6A),
        category: 'nutrition',
      ),
    ],
    'Food Cravings': [
      HealthTip(
        title: 'Dark chocolate (in moderation)',
        description:
            'Dark chocolate satisfies sweet cravings and provides magnesium that can ease PMS symptoms. Choose 70%+ cacao.',
        icon: Icons.cookie_rounded,
        color: Color(0xFF795548),
        category: 'nutrition',
      ),
      HealthTip(
        title: 'Balanced blood sugar',
        description:
            'Eating protein + complex carbs together (e.g., apple with nut butter) keeps blood sugar stable and reduces cravings.',
        icon: Icons.monitor_heart_rounded,
        color: Color(0xFFFFA726),
        category: 'nutrition',
      ),
    ],
    'Joint Pain': [
      HealthTip(
        title: 'Anti-inflammatory diet',
        description:
            'Turmeric, berries, fatty fish, and leafy greens reduce systemic inflammation that worsens joint pain before periods.',
        icon: Icons.restaurant_rounded,
        color: Color(0xFF66BB6A),
        category: 'nutrition',
      ),
      HealthTip(
        title: 'Low-impact movement',
        description:
            'Swimming, yoga, or light cycling keeps joints mobile without impact stress. Avoid high-intensity workouts during flares.',
        icon: Icons.pool_rounded,
        color: Color(0xFF42A5F5),
        category: 'exercise',
      ),
    ],
    'Anxiety': [
      HealthTip(
        title: '4-7-8 breathing',
        description:
            'Inhale for 4 counts, hold for 7, exhale for 8. This activates your parasympathetic nervous system and calms anxiety quickly.',
        icon: Icons.air_rounded,
        color: Color(0xFF29B6F6),
        category: 'self_care',
      ),
      HealthTip(
        title: 'Limit caffeine & alcohol',
        description:
            'Both substances amplify anxiety and disrupt sleep. Herbal teas like chamomile or lemon balm are calming alternatives.',
        icon: Icons.no_drinks_rounded,
        color: Color(0xFFFFA726),
        category: 'nutrition',
      ),
    ],
    'Depression': [
      HealthTip(
        title: 'Sunlight & movement',
        description:
            'A 20-minute walk outdoors combines sunlight exposure and exercise — both of which boost serotonin and vitamin D.',
        icon: Icons.wb_sunny_rounded,
        color: Color(0xFFFFC107),
        category: 'exercise',
      ),
      HealthTip(
        title: 'Social connection',
        description:
            'Even a short conversation with someone you trust can lift mood. Isolation tends to deepen low-mood feelings during PMS.',
        icon: Icons.people_rounded,
        color: Color(0xFFE91E8C),
        category: 'self_care',
      ),
    ],
    'Insomnia': [
      HealthTip(
        title: 'Consistent sleep schedule',
        description:
            'Going to bed and waking at the same time (even on weekends) regulates your circadian rhythm and improves sleep quality.',
        icon: Icons.bedtime_rounded,
        color: Color(0xFF5C6BC0),
        category: 'self_care',
      ),
      HealthTip(
        title: 'Screen-free wind-down',
        description:
            'Blue light from screens suppresses melatonin. Switch to a book, light stretching, or journaling 1 hour before bed.',
        icon: Icons.phone_android_rounded,
        color: Color(0xFFAB47BC),
        category: 'self_care',
      ),
    ],
    'Brain Fog': [
      HealthTip(
        title: 'Hydrate consistently',
        description:
            'Even 1–2% dehydration impairs memory and concentration. Keep a water bottle visible and sip throughout the day.',
        icon: Icons.water_drop_rounded,
        color: Color(0xFF29B6F6),
        category: 'self_care',
      ),
      HealthTip(
        title: 'Omega-3 brain support',
        description:
            'DHA, found in fatty fish and algae supplements, is a key building block of brain cells and supports cognitive clarity.',
        icon: Icons.psychology_rounded,
        color: Color(0xFF42A5F5),
        category: 'nutrition',
      ),
    ],
    'Spotting': [
      HealthTip(
        title: 'Track and note patterns',
        description:
            'Light spotting mid-cycle is common around ovulation. If spotting is frequent or heavy, discuss it with your doctor.',
        icon: Icons.note_alt_rounded,
        color: Color(0xFFFFA726),
        category: 'medical',
      ),
    ],
  };

  // General wellness tips shown when no specific symptom match
  static const List<HealthTip> _generalTips = [
    HealthTip(
      title: 'Track your cycle',
      description:
          'Logging symptoms consistently helps you identify patterns and prepare for each phase of your cycle.',
      icon: Icons.track_changes_rounded,
      color: Color(0xFFE91E8C),
      category: 'self_care',
    ),
    HealthTip(
      title: 'Stay hydrated',
      description:
          'Drinking 8 glasses of water daily supports hormone regulation, reduces bloating, and boosts energy levels.',
      icon: Icons.water_drop_rounded,
      color: Color(0xFF29B6F6),
      category: 'self_care',
    ),
    HealthTip(
      title: 'Regular gentle exercise',
      description:
          'Walking, yoga, or swimming for 30 minutes most days helps regulate hormones and reduces PMS severity over time.',
      icon: Icons.directions_walk_rounded,
      color: Color(0xFF42A5F5),
      category: 'exercise',
    ),
  ];

  /// Returns relevant tips for a list of symptoms.
  /// Tips for the most frequent symptoms are returned first.
  /// Falls back to general tips if no symptoms match.
  static List<HealthTip> getTipsForSymptoms(List<String> symptoms) {
    final result = <HealthTip>[];
    final seen = <String>{};

    for (final symptom in symptoms) {
      final key = _symptomTips.keys.firstWhere(
        (k) => k.toLowerCase() == symptom.toLowerCase(),
        orElse: () => '',
      );
      if (key.isNotEmpty) {
        for (final tip in _symptomTips[key]!) {
          if (!seen.contains(tip.title)) {
            seen.add(tip.title);
            result.add(tip);
          }
        }
      }
      if (result.length >= 6) break;
    }

    if (result.isEmpty) return _generalTips;
    return result;
  }

  /// Returns one tip for the most prominent symptom (for home screen card).
  static HealthTip? getTopTip(List<String> symptoms) {
    for (final symptom in symptoms) {
      final key = _symptomTips.keys.firstWhere(
        (k) => k.toLowerCase() == symptom.toLowerCase(),
        orElse: () => '',
      );
      if (key.isNotEmpty) return _symptomTips[key]!.first;
    }
    return _generalTips.first;
  }

  static String categoryLabel(String category) {
    switch (category) {
      case 'nutrition':
        return 'Nutrition';
      case 'exercise':
        return 'Exercise';
      case 'self_care':
        return 'Self-care';
      case 'medical':
        return 'Medical';
      default:
        return 'Tip';
    }
  }
}
