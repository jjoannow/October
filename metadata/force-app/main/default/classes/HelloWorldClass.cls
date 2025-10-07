public class HelloWorldClass {
    public static String sayHello(String name) {
        if (String.isBlank(name)) {
            return 'Hello, World!';
        } else {
            return 'Hello, ' + name + '!';
        }
    }
}