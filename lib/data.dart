import 'package:flutter/material.dart';

enum Method {
  chat('Chat', Icons.chat_bubble_outline_rounded),
  voice('Voice call', Icons.call_outlined),
  video('Video call', Icons.videocam_outlined);

  const Method(this.label, this.icon);
  final String label;
  final IconData icon;
}

class Astrologer {
  const Astrologer({
    required this.name,
    required this.image,
    required this.expertise,
    required this.languages,
    required this.experience,
    required this.rating,
    required this.reviews,
    required this.price,
    required this.available,
    required this.bio,
  });

  final String name;
  final String image;
  final List<String> expertise;
  final String languages;
  final int experience;
  final double rating;
  final String reviews;
  final int price;
  final bool available;
  final String bio;

  int rate(Method method) => switch (method) {
    Method.chat => price,
    Method.voice => price + 10,
    Method.video => price + 20,
  };
}

// Seed data for the local demo; availability and prices are not live API data.
const astrologers = [
  Astrologer(
    name: 'Meera Sharma',
    image: 'meera',
    expertise: ['Vedic', 'Relationships'],
    languages: 'Hindi, English',
    experience: 12,
    rating: 4.9,
    reviews: '1.2k',
    price: 35,
    available: true,
    bio:
        'Meera works with Vedic birth charts to explore recurring patterns, relationship dynamics and moments of change. Her sessions make room for your questions and help you understand the chart in everyday language.',
  ),
  Astrologer(
    name: 'Arjun Rao',
    image: 'arjun',
    expertise: ['Vedic', 'Career'],
    languages: 'Hindi, English, Telugu',
    experience: 18,
    rating: 4.9,
    reviews: '980',
    price: 45,
    available: true,
    bio:
        'Arjun specialises in Vedic astrology, with a focus on career decisions and life transitions. He uses planetary periods in your birth chart to frame a practical conversation around the choices ahead.',
  ),
  Astrologer(
    name: 'Anika Sen',
    image: 'anika',
    expertise: ['Tarot', 'Relationships'],
    languages: 'English, Bengali',
    experience: 8,
    rating: 4.8,
    reviews: '754',
    price: 30,
    available: true,
    bio:
        'Anika offers reflective tarot readings shaped around the questions you bring. She often works with people navigating relationships, personal growth and decisions that benefit from a different perspective.',
  ),
  Astrologer(
    name: 'Dev Malhotra',
    image: 'dev',
    expertise: ['Numerology', 'Career'],
    languages: 'Hindi, English, Punjabi',
    experience: 10,
    rating: 4.7,
    reviews: '510',
    price: 25,
    available: false,
    bio:
        'Dev explores how numerology can offer a different way to think about your goals and routines. His readings focus on themes of work, timing and personal direction.',
  ),
];

class ConsumerProfile {
  const ConsumerProfile({
    required this.name,
    required this.birthDate,
    required this.birthTime,
    required this.birthplace,
  });
  final String name;
  final DateTime birthDate;
  final TimeOfDay birthTime;
  final String birthplace;
}

class SessionRecord {
  const SessionRecord({
    required this.astrologer,
    required this.method,
    required this.duration,
    required this.date,
    this.disconnected = false,
  });
  final Astrologer astrologer;
  final Method method;
  final Duration duration;
  final DateTime date;
  final bool disconnected;
}

class Portrait extends StatelessWidget {
  const Portrait(
    this.astrologer, {
    this.size = 66,
    this.radius = 15,
    super.key,
  });
  final Astrologer astrologer;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: Image.asset(
      'assets/images/${astrologer.image}.webp',
      width: size,
      height: size,
      fit: BoxFit.cover,
    ),
  );
}
