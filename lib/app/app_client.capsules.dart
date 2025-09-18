import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:pool/pool.dart';
import 'package:rearch/rearch.dart';
import 'package:rearch_memory_leak_test/app/character.dart';
import 'package:rearch_memory_leak_test/app/commons.dart';

// -----------------------------------------------------------------------------
//                  01. Start client app
// -----------------------------------------------------------------------------
void Function() startClientAppCapsule(CapsuleHandle use) {
  final startPeriodicApiPolling = use(_startPeriodicApiPollingCapsule);

  return () {
    print('Client -- PID: $pid');
    startPeriodicApiPolling();
  };
}

// -----------------------------------------------------------------------------
//                  02. Start periodic API polling
// -----------------------------------------------------------------------------
void Function() _startPeriodicApiPollingCapsule(CapsuleHandle use) {
  final booted = use.data(false);
  final fetchAllCharacters = use(_fetchAllCharactersCapsule);

  final isBooted = booted.value;

  use.effect(() {
    if (!isBooted) {
      return null;
    }

    // Initial
    fetchAllCharacters();

    // Periodic
    return Timer.periodic(
      const Duration(seconds: 10),
      (_) => fetchAllCharacters(),
    ).cancel;
  }, [isBooted]);

  return () => booted.value = true;
}

// -----------------------------------------------------------------------------
//                  03. Character IDs
// -----------------------------------------------------------------------------
List<String> _characterIdsCapsule(CapsuleHandle use) {
  const characterCount = 300;

  return List.generate(characterCount, (index) => index.toString());
}

// -----------------------------------------------------------------------------
//                  04. Fetch all characters
// -----------------------------------------------------------------------------
Future<Iterable<Character>> Function() _fetchAllCharactersCapsule(
  CapsuleHandle use,
) {
  final characterIds = use(_characterIdsCapsule);
  final fetchCharacter = use(_fetchCharacterCapsule);

  return () async {
    print('Fetching ${characterIds.length} characters...');

    final characters = await characterIds
        .map((characterId) => fetchCharacter(characterId))
        .wait;

    final nullCount = characters.where((character) => character == null).length;

    if (nullCount > 0) {
      print('Error count: $nullCount');
    }

    final nonNullCharacters = characters.nonNulls;

    final notNullCount = nonNullCharacters.length;
    if (notNullCount > 0) {
      print('Success count: $notNullCount');
    }

    return nonNullCharacters;
  };
}

// -----------------------------------------------------------------------------
//                  05. Fetch character
// -----------------------------------------------------------------------------
Future<Character?> Function(String) _fetchCharacterCapsule(CapsuleHandle use) {
  final httpClient = use(_httpClientCapsule);
  final apiFetchPool = use(_apiFetchPoolCapsule);

  return (id) async {
    try {
      final res = await apiFetchPool.withResource(
        () => httpClient.get('http://$httpAddress:$httpPort/character/$id'),
      );

      return Character.fromJson(res.data);
    } catch (e) {
      print('Error fetching character: $e');
      return null;
    }
  };
}

// -----------------------------------------------------------------------------
//                  06. Other
// -----------------------------------------------------------------------------
Pool _apiFetchPoolCapsule(CapsuleHandle use) => Pool(5);

Dio _httpClientCapsule(CapsuleHandle use) => Dio();
