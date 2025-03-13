import 'dart:async';

import 'package:beepay/core/cores.dart';
import 'package:beepay/features/home/presentation/bloc/banner_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CarouselWidget extends StatefulWidget {
  @override
  State<CarouselWidget> createState() => _CarouselWidgetState();
}

class _CarouselWidgetState extends State<CarouselWidget> {
  late PageController _pageController;
  int activePage = 0;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.8, initialPage: 0);
    context.read<BannerBloc>().add(GetBannersEvent());
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void startAutoScroll(List<String> banners) {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients && banners.isNotEmpty) {
        int nextPage = (_pageController.page!.toInt() + 1) % banners.length;
        _pageController.animateToPage(nextPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BannerBloc, BannerState>(
      builder: (context, state) {
        if (state is BannerLoading) {
          return Center(child: CircularProgressIndicator(color: amber));
        } else if (state is BannerLoaded) {
          final banners = state.banners.map((e) => e.imagen).toList();
          startAutoScroll(banners);

          return Column(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 180,
                child: PageView.builder(
                  itemCount: banners.length,
                  controller: _pageController,
                  onPageChanged: (page) {
                    setState(() {
                      activePage = page;
                    });
                  },
                  itemBuilder: (context, pagePosition) {
                    return slider(
                        banners, pagePosition, pagePosition == activePage);
                  },
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: indicators(banners.length, activePage),
              ),
            ],
          );
        } else if (state is BannerError) {
          return Center(
              child: Text("Error al cargar banners",
                  style: semibold(Colors.red, 14)));
        }
        return Container();
      },
    );
  }

  AnimatedContainer slider(List<String> images, int pagePosition, bool active) {
    double margin = active ? 5 : 10;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
      margin: EdgeInsets.all(margin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        image: DecorationImage(
          image: NetworkImage(images[pagePosition]),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  List<Widget> indicators(int imagesLength, int currentIndex) {
    return List.generate(imagesLength, (index) {
      return Container(
        margin: const EdgeInsets.all(3),
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: currentIndex == index ? Colors.black : Colors.black26,
          shape: BoxShape.circle,
        ),
      );
    });
  }
}
