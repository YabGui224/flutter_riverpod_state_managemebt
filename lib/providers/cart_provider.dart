import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_exemple/models/product.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cart_provider.g.dart';

@riverpod
class CartNotifier extends _$CartNotifier{

    // Initial value
    @override
    Set<Product> build() {
      return {

      };
    }

    // methods to update state
    void addProduct(Product product) {
      if ( !state.any((p) => p.id == product.id)) {
        state = {...state, product};
      }
    }

    void removeProduct(Product product) {
      state = state.where((p) => p.id != product.id).toSet();
    }
}

// create a provider for notifier
// final cartNotifierProvider = NotifierProvider<CartNotifier, Set<Product>>(() {
//   return CartNotifier();
// });

@riverpod
int cartTotal(ref) {
  final cartProducts = ref.watch(cartProvider);

  int total = 0;
  for (Product product in cartProducts) {
    total += product.price;
  }
  return total;
}

