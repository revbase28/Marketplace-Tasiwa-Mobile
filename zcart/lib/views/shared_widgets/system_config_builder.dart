import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zcart/data/models/system_config_model.dart';
import 'package:zcart/riverpod/providers/system_config_provider.dart';

class SystemConfigBuilder extends ConsumerWidget {
  final Widget Function(BuildContext context, ConfigData? systemConfig) builder;
  const SystemConfigBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, watch) {
    final _systemConfigProvider = watch(systemConfigFutureProvider);

    return _systemConfigProvider.when(
      data: (value) {
        return builder(context, value?.data);
      },
      loading: () => builder(context, null),
      error: (e, stackTrace) => builder(context, null),
    );
  }
}
