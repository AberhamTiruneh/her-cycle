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
      HealthTip(
        title: 'Anti-inflammatory diet',
        description:
            'Turmeric, ginger, and omega-3-rich foods reduce prostaglandins — the hormones that cause uterine cramping.',
        icon: Icons.eco_rounded,
        color: Color(0xFF26A69A),
        category: 'nutrition',
      ),
      HealthTip(
        title: 'Gentle yoga poses',
        description:
            "Child's pose and supine twist stretch the lower abdomen and back, releasing tension and reducing cramp intensity.",
        icon: Icons.self_improvement_rounded,
        color: Color(0xFF5C6BC0),
        category: 'exercise',
      ),
      HealthTip(
        title: 'Stay active',
        description:
            'Light movement like walking increases blood flow to the uterus and triggers endorphin release, acting as a natural painkiller.',
        icon: Icons.directions_walk_rounded,
        color: Color(0xFF42A5F5),
        category: 'exercise',
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
      HealthTip(
        title: 'Try a potassium-rich snack',
        description:
            'Bananas, avocado, and sweet potato are high in potassium, which counters sodium and flushes excess water.',
        icon: Icons.restaurant_rounded,
        color: Color(0xFF66BB6A),
        category: 'nutrition',
      ),
      HealthTip(
        title: 'Light walk after meals',
        description:
            'A 10-minute walk after eating speeds up gastric emptying and significantly reduces post-meal bloating.',
        icon: Icons.directions_walk_rounded,
        color: Color(0xFF42A5F5),
        category: 'exercise',
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
      HealthTip(
        title: 'B12 and folate foods',
        description:
            'Eggs, fortified cereals, and legumes provide B12 and folate that support red blood cell production and reduce tiredness.',
        icon: Icons.egg_rounded,
        color: Color(0xFFFFA726),
        category: 'nutrition',
      ),
      HealthTip(
        title: 'Short power nap',
        description:
            'A 20-minute nap between 1–3 pm restores alertness without causing grogginess. Set an alarm to avoid oversleeping.',
        icon: Icons.airline_seat_flat_rounded,
        color: Color(0xFF5C6BC0),
        category: 'self_care',
      ),
      HealthTip(
        title: 'Limit caffeine after noon',
        description:
            'Caffeine has a 5–7 hour half-life. Cutting it off after 12 pm protects sleep quality and prevents next-day energy crashes.',
        icon: Icons.no_drinks_rounded,
        color: Color(0xFFEF5350),
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
      HealthTip(
        title: 'Cold or warm compress',
        description:
            'A cold compress on your forehead constricts blood vessels and dulls pain. A warm compress on your neck relaxes tension headaches.',
        icon: Icons.ac_unit_rounded,
        color: Color(0xFF42A5F5),
        category: 'self_care',
      ),
      HealthTip(
        title: 'Consistent meal times',
        description:
            'Skipping meals drops blood sugar, which is a common headache trigger. Eat balanced meals at regular intervals throughout the day.',
        icon: Icons.schedule_rounded,
        color: Color(0xFF66BB6A),
        category: 'nutrition',
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
      HealthTip(
        title: 'Journal your feelings',
        description:
            'Writing down emotions for 5 minutes helps process them and reduce their intensity. It also reveals patterns across your cycle.',
        icon: Icons.edit_note_rounded,
        color: Color(0xFFF06292),
        category: 'self_care',
      ),
      HealthTip(
        title: 'Reduce sugar spikes',
        description:
            'Blood sugar crashes worsen irritability. Replace sugary snacks with protein + healthy fat combos like nuts or yogurt.',
        icon: Icons.monitor_heart_rounded,
        color: Color(0xFFFFA726),
        category: 'nutrition',
      ),
      HealthTip(
        title: 'Chamomile tea ritual',
        description:
            'Chamomile has mild anxiolytic properties. A warm cup in the evening creates a calming ritual that helps regulate emotions.',
        icon: Icons.local_cafe_rounded,
        color: Color(0xFF26A69A),
        category: 'self_care',
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
    HealthTip(
      title: 'Prioritize sleep',
      description:
          'Going to bed at the same time each night regulates cortisol and helps balance reproductive hormones throughout your cycle.',
      icon: Icons.bedtime_rounded,
      color: Color(0xFF5C6BC0),
      category: 'self_care',
    ),
    HealthTip(
      title: 'Eat more leafy greens',
      description:
          'Spinach, kale, and broccoli are rich in iron, folate, and calcium — all key nutrients for menstrual health.',
      icon: Icons.eco_rounded,
      color: Color(0xFF66BB6A),
      category: 'nutrition',
    ),
    HealthTip(
      title: 'Reduce stress daily',
      description:
          'Chronic stress disrupts the hypothalamus-pituitary-ovarian axis, which can delay or irregularise your cycle. Even 10 minutes of deep breathing helps.',
      icon: Icons.self_improvement_rounded,
      color: Color(0xFF26A69A),
      category: 'self_care',
    ),
    HealthTip(
      title: 'Limit ultra-processed foods',
      description:
          'High-sugar and highly processed foods spike insulin and can worsen hormonal imbalances. Opt for whole foods as much as possible.',
      icon: Icons.no_food_rounded,
      color: Color(0xFFFFA726),
      category: 'nutrition',
    ),
    HealthTip(
      title: 'Get enough vitamin D',
      description:
          'Vitamin D deficiency is linked to heavier periods and increased PMS. Spend 15 minutes in morning sunlight or consider a supplement.',
      icon: Icons.wb_sunny_rounded,
      color: Color(0xFFFFC107),
      category: 'nutrition',
    ),
    HealthTip(
      title: 'Try cycle syncing',
      description:
          'Matching your workouts and diet to each phase — follicular, ovulation, luteal, menstrual — can significantly improve energy and mood.',
      icon: Icons.loop_rounded,
      color: Color(0xFFE91E8C),
      category: 'self_care',
    ),
    HealthTip(
      title: 'Practice mindful eating',
      description:
          'Eating slowly and without distractions improves digestion and helps you tune into hunger cues, which often shift across your cycle.',
      icon: Icons.restaurant_rounded,
      color: Color(0xFF66BB6A),
      category: 'nutrition',
    ),
  ];

  /// Returns relevant tips for a list of symptoms, rotated daily.
  /// Tips for the most frequent symptoms are returned first.
  /// Falls back to general tips if no symptoms match.
  static List<HealthTip> getTipsForSymptoms(List<String> symptoms) {
    final result = <HealthTip>[];
    final seen = <String>{};

    // Daily rotation seed — changes every day
    final daySeed = DateTime.now().difference(DateTime(2024)).inDays;

    for (final symptom in symptoms) {
      final key = _symptomTips.keys.firstWhere(
        (k) => k.toLowerCase() == symptom.toLowerCase(),
        orElse: () => '',
      );
      if (key.isNotEmpty) {
        final tips = List<HealthTip>.from(_symptomTips[key]!);
        // Rotate the tips list based on day so order changes daily
        final offset = daySeed % tips.length;
        final rotated = [...tips.sublist(offset), ...tips.sublist(0, offset)];
        for (final tip in rotated) {
          if (!seen.contains(tip.title)) {
            seen.add(tip.title);
            result.add(tip);
          }
        }
      }
      if (result.length >= 6) break;
    }

    if (result.isEmpty) {
      // Rotate general tips daily
      final daySeed = DateTime.now().difference(DateTime(2024)).inDays;
      final tips = List<HealthTip>.from(_generalTips);
      final offset = daySeed % tips.length;
      return [...tips.sublist(offset), ...tips.sublist(0, offset)];
    }
    return result;
  }

  /// Returns one tip for the most prominent symptom, rotated daily.
  static HealthTip? getTopTip(List<String> symptoms) {
    final daySeed = DateTime.now().difference(DateTime(2024)).inDays;

    for (final symptom in symptoms) {
      final key = _symptomTips.keys.firstWhere(
        (k) => k.toLowerCase() == symptom.toLowerCase(),
        orElse: () => '',
      );
      if (key.isNotEmpty) {
        final tips = _symptomTips[key]!;
        return tips[daySeed % tips.length];
      }
    }
    return _generalTips[daySeed % _generalTips.length];
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
