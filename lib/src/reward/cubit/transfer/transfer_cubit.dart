import '../../../proxys/erc20/brlc/brlc_proxy.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:web3dart/web3dart.dart';

part 'transfer_cubit.freezed.dart';
part 'transfer_state.dart';

class TransferCubit extends Cubit<TransferState> {
  final Credentials credentials;
  final BrlcProxy brlcProxy;

  TransferCubit({
    required this.credentials,
    required this.brlcProxy,
  }) : super(const TransferState.initial());

  Future<void> transfer({
    required String address,
    required double amount,
  }) async {
    try {
      emit(const TransferState.loading());

      final account = await credentials.extractAddress();
      final currentBalance = await brlcProxy.balanceOf(
        address: account.hex,
      );

      if (currentBalance >= amount) {
        final tx = await brlcProxy.transfer(
          from: address,
          credentials: credentials,
          amount: amount,
        );

        emit(TransferState.success(tx: tx));
      } else {
        emit(const TransferState.error(message: 'Insufficient balance'));
      }
    } catch (_) {
      emit(const TransferState.error(message: 'Something goes wrong'));
    }
  }
}
