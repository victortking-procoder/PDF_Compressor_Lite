import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ad_service.dart';

class LimitDialog extends StatefulWidget {
  const LimitDialog({super.key});

  @override
  State<LimitDialog> createState() => _LimitDialogState();
}

class _LimitDialogState extends State<LimitDialog> {
  bool _isLoadingAd = false;
  bool _adReady = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange),
          SizedBox(width: 12),
          Text('Free Limit Reached'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'You\'ve used all your free compressions for today.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.play_circle_outline, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Watch a short ad to unlock 2 more compressions',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade900,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Not Now'),
        ),
        FilledButton.icon(
          onPressed: _isLoadingAd
              ? null
              : () {
                  if (_adReady) {
                    _showRewardedAd();
                  } else {
                    _loadRewardedAd();
                  }
                },
          icon: _isLoadingAd
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.play_arrow),
          label: Text(_isLoadingAd
              ? 'Loading...'
              : _adReady
                  ? 'Watch Ad'
                  : 'Watch Ad'),
        ),
      ],
    );
  }

  void _loadRewardedAd() {
    setState(() {
      _isLoadingAd = true;
    });

    final adService = context.read<AdService>();
    adService.loadRewardedAd(
      onAdLoaded: () {
        if (mounted) {
          setState(() {
            _isLoadingAd = false;
            _adReady = true;
          });
          _showRewardedAd();
        }
      },
      onAdFailedToLoad: () {
        if (mounted) {
          setState(() {
            _isLoadingAd = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to load ad. Please try again later.'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.pop(context);
        }
      },
    );
  }

  Future<void> _showRewardedAd() async {
    final adService = context.read<AdService>();
    final success = await adService.showRewardedAd();

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Unlocked ${AdService.rewardedAdBonus} more compressions!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        Navigator.pop(context);
      }
    }
  }
}
