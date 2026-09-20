// Extra rule providers for the current Clash Verge subscription.
// Routing order is managed by the subscription's Rules enhancement file.
function main(config) {
  const proxyGroup = "狗狗加速.com";
  const source = "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/meta/geo/";
  const common = { type: "http", format: "mrs", interval: 86400, proxy: proxyGroup };

  const additions = {
    "self-private-domain": {
      ...common, behavior: "domain", path: "./ruleset/self/private-domain.mrs",
      url: source + "geosite/private.mrs"
    },
    "self-cn-domain": {
      ...common, behavior: "domain", path: "./ruleset/self/cn-domain.mrs",
      url: source + "geosite/cn.mrs"
    },
    "self-foreign-domain": {
      ...common, behavior: "domain", path: "./ruleset/self/foreign-domain.mrs",
      url: source + "geosite/geolocation-!cn.mrs"
    },
    "self-cn-ip": {
      ...common, behavior: "ipcidr", path: "./ruleset/self/cn-ip.mrs",
      url: source + "geoip/cn.mrs"
    }
  };

  config["rule-providers"] = { ...(config["rule-providers"] || {}), ...additions };

  return config;
}
