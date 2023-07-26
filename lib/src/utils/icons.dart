import 'package:flutter_svg/flutter_svg.dart';
import 'package:likeminds_feed_ss_fl/src/utils/constants/assets_constants.dart';

Future loadSvgIntoCache() async {
  for (String assetPath in svgAssets) {
    SvgAssetLoader loader = SvgAssetLoader(assetPath);
    svg.cache.putIfAbsent(loader.cacheKey(null), () => loader.loadBytes(null));
  }
}
