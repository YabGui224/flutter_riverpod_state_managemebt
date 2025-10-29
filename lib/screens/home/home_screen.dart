import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_exemple/models/product.dart';
import 'package:flutter_riverpod_exemple/providers/cart_provider.dart';
import 'package:flutter_riverpod_exemple/providers/products_provider.dart';
import 'package:flutter_riverpod_exemple/shared/cart_icon.dart';

// Declaration du Consumer sur un StatelessWidget
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allProducts = ref.watch(productsProvider);
    final cartProducts = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Garage Sale Products'),
        actions: const [CartIcon()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.builder(
          itemCount: allProducts.length,
          gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 0.9,
          ),
          itemBuilder:(context, index) {
            Product product = allProducts[index];
            bool inCart = cartProducts.any((cp) => cp.id == product.id);

            return Container(
              padding: const EdgeInsets.only(top: 10),
              color: Colors.blueGrey.withAlpha(50),
              child: Column(
                children: [
                  Image.asset(product.image, width: 60, height: 60,),
                  Text(product.title),
                  Text("${product.price}"),

                  if (inCart)
                    TextButton(onPressed: () {
                      ref.read(cartProvider.notifier).removeProduct(product);
                    }, child: Text("Remove"))
                  else
                    TextButton(onPressed: () {
                      ref.read(cartProvider.notifier).addProduct(product);
                    }, child: Text("Add to Cart")),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}