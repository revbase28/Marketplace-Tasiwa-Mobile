import 'package:flutter_riverpod/flutter_riverpod.dart';

class Logger extends ProviderObserver {
  @override
  void didUpdateProvider(ProviderBase provider, Object? newValue) {
    //debugPrint('["didUpdateProvider": "${provider.name ?? provider.runtimeType}", "newValue": "$newValue"]');
  }
}
