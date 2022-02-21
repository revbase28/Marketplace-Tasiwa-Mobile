import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zcart/riverpod/providers/system_config_provider.dart';

class CurrencySymbolWidget extends ConsumerWidget {
  final Widget Function(BuildContext context, String? symbol) builder;
  const CurrencySymbolWidget({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, watch) {
    final _systemConfigProvider = watch(systemConfigFutureProvider);

    return _systemConfigProvider.when(
      data: (value) {
        if (value == null) {
          return builder(context, null);
        } else {
          return builder(context, value.data?.currency?.symbol);
        }
      },
      loading: () => builder(context, null),
      error: (e, stackTrace) => builder(context, null),
    );
  }
}

class CurrencyWidget extends ConsumerWidget {
  final Widget Function(BuildContext context, String? symbol) builder;
  const CurrencyWidget({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, watch) {
    final _systemConfigProvider = watch(systemConfigFutureProvider);

    return _systemConfigProvider.when(
      data: (value) {
        if (value == null) {
          return builder(context, null);
        } else {
          return builder(context, value.data?.currency?.isoCode);
        }
      },
      loading: () => builder(context, null),
      error: (e, stackTrace) => builder(context, null),
    );
  }
}
