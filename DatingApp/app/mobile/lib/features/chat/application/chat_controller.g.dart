// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Streams the most-recent message window for a conversation (realtime) and
/// grows the window to page in older messages. Keyed by the other user's uid.

@ProviderFor(ChatController)
final chatControllerProvider = ChatControllerFamily._();

/// Streams the most-recent message window for a conversation (realtime) and
/// grows the window to page in older messages. Keyed by the other user's uid.
final class ChatControllerProvider
    extends $NotifierProvider<ChatController, ChatState> {
  /// Streams the most-recent message window for a conversation (realtime) and
  /// grows the window to page in older messages. Keyed by the other user's uid.
  ChatControllerProvider._({
    required ChatControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'chatControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chatControllerHash();

  @override
  String toString() {
    return r'chatControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ChatController create() => ChatController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ChatControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chatControllerHash() => r'343becdb8f6447a75940998a6ff318cad4340f01';

/// Streams the most-recent message window for a conversation (realtime) and
/// grows the window to page in older messages. Keyed by the other user's uid.

final class ChatControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          ChatController,
          ChatState,
          ChatState,
          ChatState,
          String
        > {
  ChatControllerFamily._()
    : super(
        retry: null,
        name: r'chatControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Streams the most-recent message window for a conversation (realtime) and
  /// grows the window to page in older messages. Keyed by the other user's uid.

  ChatControllerProvider call(String otherUid) =>
      ChatControllerProvider._(argument: otherUid, from: this);

  @override
  String toString() => r'chatControllerProvider';
}

/// Streams the most-recent message window for a conversation (realtime) and
/// grows the window to page in older messages. Keyed by the other user's uid.

abstract class _$ChatController extends $Notifier<ChatState> {
  late final _$args = ref.$arg as String;
  String get otherUid => _$args;

  ChatState build(String otherUid);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ChatState, ChatState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ChatState, ChatState>,
              ChatState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
