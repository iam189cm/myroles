// Portable rule providers and a selectable outbound group.
// Routing order is managed by the subscription's Rules enhancement file.
function main(config) {
  const proxyGroup = "自选代理";
  const groups = Array.isArray(config["proxy-groups"]) ? config["proxy-groups"] : [];
  if (!groups.some(group => group.name === proxyGroup)) {
    const preferred = groups.find(group =>
      group.type === "select" && Array.isArray(group.proxies) && group.proxies.length > 0
    );
    const selectable = { name: proxyGroup, type: "select", "include-all": true };
    if (preferred) {
      selectable.proxies = [preferred.name];
      selectable["default-selected"] = preferred.name;
    }
    config["proxy-groups"] = [selectable, ...groups];
  }

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
