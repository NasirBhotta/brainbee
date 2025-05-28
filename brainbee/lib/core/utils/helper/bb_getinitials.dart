String getIntials(String fullName) {
  List<String> names = fullName.trim().split(' ');
  if (names.isEmpty) return '';
  if (names.length == 1) return names[0][0].toUpperCase();
  String initials = names.map((e) => e[0]).take(2).join().toUpperCase();
  return initials;
}
