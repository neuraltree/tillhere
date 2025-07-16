/// Navigation item entity representing a menu item in the side drawer
/// Following Clean Architecture principles - pure domain entity
class NavigationItem {
  final String id;
  final String title;
  final String icon; // Emoji icon
  final String route;
  final bool isActive;

  const NavigationItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.route,
    this.isActive = false,
  });

  /// Creates a copy of this navigation item with updated properties
  NavigationItem copyWith({
    String? id,
    String? title,
    String? icon,
    String? route,
    bool? isActive,
  }) {
    return NavigationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      route: route ?? this.route,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NavigationItem &&
        other.id == id &&
        other.title == title &&
        other.icon == icon &&
        other.route == route &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        icon.hashCode ^
        route.hashCode ^
        isActive.hashCode;
  }

  @override
  String toString() {
    return 'NavigationItem(id: $id, title: $title, icon: $icon, route: $route, isActive: $isActive)';
  }
}
