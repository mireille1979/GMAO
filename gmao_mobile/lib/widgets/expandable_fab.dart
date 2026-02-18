import 'package:flutter/material.dart';
import '../utils/theme.dart';

@immutable
class FabAction {
  final Widget icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const FabAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });
}

@immutable
class ExpandableFab extends StatefulWidget {
  const ExpandableFab({
    super.key,
    this.initialOpen,
    required this.distance,
    required this.actions,
  });

  final bool? initialOpen;
  final double distance;
  final List<FabAction> actions;

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _isOpen = widget.initialOpen ?? false;
    _controller = AnimationController(
      value: _isOpen ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _removeOverlay();
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_isOpen) {
      _controller.reverse().then((_) {
        _removeOverlay();
        if (mounted) setState(() => _isOpen = false);
      });
    } else {
      setState(() => _isOpen = true);
      _createOverlay();
      _controller.forward();
    }
  }

  void _hide() {
    if (_isOpen) {
       _controller.reverse().then((_) {
        _removeOverlay();
        if (mounted) setState(() => _isOpen = false);
      });
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _createOverlay() {
    _removeOverlay();
    
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    
    // We want to position the menu right above the FAB.
    // The FAB's top-left in global coordinates is `offset`.
    // The menu should be anchored to the bottom-right of the FAB, but growing upwards.
    // Actually simpler: The menu bottom-right should align with FAB top-right or center.
    
    // FAB is usually 56x56.
    // Let's position the menu stack such that its bottom-right is at (offset.dx + size.width, offset.dy - 10).
    
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // Modal barrier
             Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _toggle,
                child: Container(color: Colors.black.withOpacity(0.0)),
              ),
            ),
            
            // Menu Items
            Positioned(
              right: MediaQuery.of(context).size.width - (offset.dx + size.width), // Align right edge
              bottom: MediaQuery.of(context).size.height - offset.dy + 10, // Align bottom edge to top of FAB + spacer
              child: FadeTransition(
                opacity: _expandAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: widget.actions.map((action) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: _ActionButton(
                          icon: action.icon,
                          label: action.label,
                          color: action.color,
                          onPressed: () {
                            _hide();
                            action.onPressed();
                          },
                        ),
                      );
                  }).toList(),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'expandable_fab_main',
      backgroundColor: AppTheme.primaryTeal,
      onPressed: _toggle,
      child: AnimatedIcon(
        icon: AnimatedIcons.menu_close,
        progress: _controller,
      ),
    );
  }
}

@immutable
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    this.color = AppTheme.primaryTeal,
  });

  final VoidCallback? onPressed;
  final Widget icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Material(
          color: Colors.white,
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textDark),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        FloatingActionButton.small(
          heroTag: null,
          backgroundColor: color,
          onPressed: onPressed,
          child: icon,
        ),
      ],
    );
  }
}
