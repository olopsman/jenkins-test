@isTest
private class HeartBeatTester {
	@isTest static void testHeartBeat() {
		Test.startTest();
		system.schedule('HeartBeat', '0 0 * * * ?', new HeartBeat());
		Test.stopTest();
	}	
}