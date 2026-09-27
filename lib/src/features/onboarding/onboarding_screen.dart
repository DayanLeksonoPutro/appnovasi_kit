import 'package:flutter/material.dart';

import '../../../l10n/gen/app_localizations.dart';
import 'onboarding_config.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.pages,
    this.onFinish,
    this.showSkip = true,
    this.showIndicator = true,
    this.allowBack = true,
  });

  final List<OnboardingPage> pages;
  final VoidCallback? onFinish;
  final bool showSkip;
  final bool showIndicator;
  final bool allowBack;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  bool get _isLast => _index >= widget.pages.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_isLast) {
      widget.onFinish?.call();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _back() {
    _controller.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: widget.showSkip && !_isLast
                  ? TextButton(
                      onPressed: widget.onFinish,
                      child: Text(l10n.onboardingSkip),
                    )
                  : const SizedBox(height: 48),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: widget.pages.length,
                onPageChanged: (value) => setState(() => _index = value),
                itemBuilder: (context, index) =>
                    _PageContent(page: widget.pages[index]),
              ),
            ),
            if (widget.showIndicator)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.pages.length, (index) {
                    final active = index == _index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: active ? 24 : 8,
                      decoration: BoxDecoration(
                        color: active
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Row(
                children: [
                  if (widget.allowBack && _index > 0)
                    IconButton.outlined(
                      onPressed: _back,
                      icon: const Icon(Icons.arrow_back),
                    ),
                  if (widget.allowBack && _index > 0) const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _next,
                      child: Text(
                        _isLast
                            ? l10n.onboardingGetStarted
                            : l10n.onboardingNext,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageContent extends StatelessWidget {
  const _PageContent({required this.page});

  final OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final media = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: media.height * 0.32,
            child: Center(child: _buildVisual(theme)),
          ),
          const SizedBox(height: 32),
          if (page.title != null)
            Text(
              page.title!,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          if (page.description != null) ...[
            const SizedBox(height: 12),
            Text(
              page.description!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVisual(ThemeData theme) {
    if (page.imageAsset != null) {
      return Image.asset(page.imageAsset!, fit: BoxFit.contain);
    }
    return Icon(
      page.icon ?? Icons.auto_awesome,
      size: 120,
      color: theme.colorScheme.primary,
    );
  }
}
