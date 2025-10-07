@IsTest
private class HelloWorldClassTest {
    @IsTest static void testSayHello() {
        System.assertEquals('Hello, Jennifer!', HelloWorldClass.sayHello('Jennifer'));
        System.assertEquals('Hello, World!', HelloWorldClass.sayHello(null));
    }
}