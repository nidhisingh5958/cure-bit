import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
// import 'package:provider/provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;

  int _pageIndex = 0;

  @override
  void initState() {
    _pageController = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  itemCount: onBoardData.length,
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _pageIndex = index;
                    });
                  },
                  itemBuilder: (context, index) => OnboardContent(
                    image: onBoardData[index].image,
                    title: onBoardData[index].title,
                    description: onBoardData[index].description,
                  ),
                ),
              ),
              Row(
                children: [
                  ...List.generate(
                    onBoardData.length,
                    (index) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DotIndicator(isActive: index == _pageIndex),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 60,
                    width: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        // if (_pageController.page == 2) {
                        //   Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //       builder: (context) => const Login(),
                        //     ),
                        //   );
                        // } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                        // }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                      ),
                      child: SvgPicture.asset(
                        'assets/icons/arrow_right.svg',
                        colorFilter: ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DotIndicator extends StatelessWidget {
  const DotIndicator({
    this.isActive = false,
    super.key,
  });

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: isActive ? 12 : 4,
      width: 4,
      decoration: BoxDecoration(
        color: isActive ? Theme.of(context).colorScheme.primary : null,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
    );
  }
}

class OnBoard {
  final String image;
  final String title;
  final String description;

  OnBoard(
      {required this.image, required this.title, required this.description});
}

final List<OnBoard> onBoardData = [
  OnBoard(
    image: 'assets/images/onboarding.png',
    title: 'Welcome to CureBit',
    description:
        'Your health is our priority. Let us help you take care of it.',
  ),
  OnBoard(
    image: 'assets/images/onboarding_2.png',
    title: 'Your personal health record maintainer.',
    description: 'Access your health records anytime, anywhere.',
  ),
  OnBoard(
    image: 'assets/images/onboarding_3.png',
    title: 'Your personal appointment tracker.',
    description: 'Never miss an appointment again.',
  ),
];

class OnboardContent extends StatelessWidget {
  const OnboardContent({
    required this.image,
    required this.title,
    required this.description,
    super.key,
  });

  final String image, title, description;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        Image.asset(
          image,
          height: 300,
        ),
        const Spacer(),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),
        Text(
          description,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const Spacer(),
      ],
    );
  }
}