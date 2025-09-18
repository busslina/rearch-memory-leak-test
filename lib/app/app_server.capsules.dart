import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:rearch/rearch.dart';
import 'package:rearch_memory_leak_test/app/character.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

import 'commons.dart';

// -----------------------------------------------------------------------------
//                  01. Start server app
// -----------------------------------------------------------------------------
void Function() startServerAppCapsule(CapsuleHandle use) {
  final entryHandler = use(_entryHttpHandlerCapsule);

  return () {
    print('Server -- PID: $pid');
    serve(entryHandler, InternetAddress.loopbackIPv4, httpPort);
    print('Serving at http://$httpAddress:$httpPort');
  };
}

// -----------------------------------------------------------------------------
//                  02. Entry HTTP handler
// -----------------------------------------------------------------------------
Handler _entryHttpHandlerCapsule(CapsuleHandle use) {
  final mockCharacterByIdHttpHandler = use(
    _mockCharacterByIdHttpHandlerCapsule,
  );

  // Error
  if (!use.isFirstBuild()) {
    throw ('Entry HTTP handler is not supposed to rebuild');
  }

  return (Router()..get('/character/<id>', mockCharacterByIdHttpHandler)).call;
}

// -----------------------------------------------------------------------------
//                  03. Mock character by id HTTP handler
// -----------------------------------------------------------------------------
FutureOr<Response> Function(Request, String)
_mockCharacterByIdHttpHandlerCapsule(CapsuleHandle use) {
  final generateMockCharacterById = use(_generateMockCharacterByIdCapsule);

  return (req, id) async {
    await Future.delayed(const Duration(milliseconds: 750));
    return Response.ok(
      jsonEncode(generateMockCharacterById(id).toJson()),
      headers: {'Content-Type': 'text/json'},
    );
  };
}

// -----------------------------------------------------------------------------
//                  04. Generate mock character by id
// -----------------------------------------------------------------------------
Character Function(String) _generateMockCharacterByIdCapsule(
  CapsuleHandle use,
) {
  return (id) {
    return Character(
      id: id,
      createdAt: DateTime.now(),
      name: 'Name $id',
      avatar: 'Url $id',
    );
  };
}

// -----------------------------------------------------------------------------
//                  05. Other
// -----------------------------------------------------------------------------
typedef Box<T> = ValueWrapper<T>;

extension on SideEffectRegistrar {
  // SideEffectRegistrar get use => this;

  /// Assures that the underlying data is updated. Even if you capture a non up to date
  /// capsule value.
  // Box<T> box<T>(T value) => use.data(value)..value = (value);
}
