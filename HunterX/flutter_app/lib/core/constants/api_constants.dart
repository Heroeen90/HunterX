class ApiConstants {
  ApiConstants._();

  static const String defaultBaseUrl = 'http://192.168.1.1:5000/api';
  static const String defaultWsUrl = 'ws://192.168.1.1:5000/ws/terminal';

  // Route paths
  static const String health = '/healthz';
  static const String systemInfo = '/system/info';
  static const String systemTools = '/system/tools';
  static const String systemNetwork = '/system/network';

  static const String nmapScan = '/nmap/scan';
  static const String nmapPingSweep = '/nmap/ping-sweep';

  static const String niktoScan = '/nikto/scan';

  static const String sqlmapScan = '/sqlmap/scan';

  static const String aircrackInterfaces = '/aircrack/interfaces';
  static const String aircrackCrack = '/aircrack/crack';

  static const String dnsLookup = '/dns/lookup';
  static const String dnsWhois = '/dns/whois';
  static const String dnsSubfinder = '/dns/subfinder';
  static const String dnsReverse = '/dns/reverse';

  static const String hashcatCrack = '/hashcat/crack';
  static const String hashcatIdentify = '/hashcat/identify';

  static const String captureInterfaces = '/capture/interfaces';
  static const String captureStart = '/capture/start';
  static const String captureStop = '/capture/stop';
  static const String captureDownload = '/capture/download';

  static const String metasploitRun = '/metasploit/run';
  static const String metasploitModules = '/metasploit/modules';

  // Request timeouts
  static const Duration shortTimeout = Duration(seconds: 10);
  static const Duration mediumTimeout = Duration(minutes: 2);
  static const Duration longTimeout = Duration(minutes: 10);
}
