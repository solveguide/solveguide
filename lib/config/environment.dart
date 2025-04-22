class EnvironmentConfig {
  static const env = String.fromEnvironment('ENV', defaultValue: 'prod');
  static const magicLinkRedirectUrl = String.fromEnvironment(
    'MAGIC_LINK_REDIRECT_URL',
    defaultValue: 'https://app.solve.guide/magic-login',
  );
  static const linkDomain = String.fromEnvironment(
    'LINK_DOMAIN',
    defaultValue: 'solve.guide',
  );
}
