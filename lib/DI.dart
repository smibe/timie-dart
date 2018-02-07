
class DI
{
  static Map<String, Object> instances = new Map<String, Object>();
  static void setInstance<T>(T instance) {
    instances[T.toString()] = instance;
  }

  static T resolve<T>() {
    return  instances[T.toString()] as T;
  }
}