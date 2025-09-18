import 'package:rearch/rearch.dart';
import 'package:rearch_memory_leak_test/app/app_client.capsules.dart';
import 'package:rearch_memory_leak_test/app/app_server.capsules.dart';

void main(List<String> arguments) {
  if (arguments.length != 1) {
    throw ('Bad usage. Use: "--server" or "--client"');
  }

  switch (arguments.single.trim().toLowerCase()) {
    case '--server':
      final capsuleContainer = CapsuleContainer();

      // Starting app
      capsuleContainer.read(startServerAppCapsule)();

    case '--client':
      final capsuleContainer = CapsuleContainer();

      // Starting app
      capsuleContainer.read(startClientAppCapsule)();
  }
}
