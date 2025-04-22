enum AppRoutes {
  auth('/auth'),
  home('/home'),
  contact('/contact'),
  dashboard('/dashboard'),
  login('/login'),
  issue('/issue'),
  profile('/profile'),
  magicLogin('/magic-login');

  const AppRoutes(this.route);

  final String route;
}
