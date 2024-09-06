import 'package:get/get.dart';
import '../../providers/product_provider.dart';
import '../../models/product.dart';

class ProductController extends GetxController {
  ProductProvider productProvider = ProductProvider();
  var products = <Product>[].obs;
  var isLoading = true.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      isLoading(true);
      var result = await ProductProvider().getProducts();
      products.assignAll(result);
    } catch (e) {
      errorMessage(e.toString());
    } finally {
      isLoading(false);
    }
  }
}
