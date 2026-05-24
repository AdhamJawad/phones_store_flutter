import 'package:flutter/material.dart';

import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/app_network_image.dart';

class ProductImageViewer extends StatefulWidget {
  const ProductImageViewer({
    required this.imageUrls,
    required this.initialIndex,
    super.key,
  });

  final List<String> imageUrls;
  final int initialIndex;

  @override
  State<ProductImageViewer> createState() => _ProductImageViewerState();
}

class _ProductImageViewerState extends State<ProductImageViewer> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: const AppBackButton(),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('${_currentIndex + 1}/${widget.imageUrls.length}'),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.imageUrls.length,
        onPageChanged: (value) {
          setState(() {
            _currentIndex = value;
          });
        },
        itemBuilder: (context, index) {
          return Center(
            child: AppNetworkImage(
              imageUrl: widget.imageUrls[index],
              fit: BoxFit.contain,
            ),
          );
        },
      ),
    );
  }
}
