enum Environment { dev, staging, prod }

class AppConfig {
  static Environment environment = Environment.dev;
  
  static String get apiUrl {
    switch (environment) {
      case Environment.dev:
        return 'https://dev-api.chamdtech-nrcs.com';
      case Environment.staging:
        return 'https://staging-api.chamdtech-nrcs.com';
      case Environment.prod:
        return 'https://api.chamdtech-nrcs.com';
    }
  }

  static String get apiKey {
    // Ideally, keys should be injected at build time using dart-define
    // This is a placeholder for demonstration
    switch (environment) {
      case Environment.dev:
        return 'DEV_API_KEY';
      case Environment.staging:
        return 'STAGING_API_KEY';
      case Environment.prod:
        return 'PROD_API_KEY';
    }
  }

  static void setEnvironment(Environment env) {
    environment = env;
  }
}
