// WQ Files Custom Inspector API 1. No imports, I/O, logging or mutation.
function inspect(input) {
  const warning = "只读结果，不修改文件。令牌存在或上传时间存在均不代表远程推送已恢复；磁盘偏好设置也不一定等于当前进程中的值。";
  if (input.truncated) {
    return { title: "抖音推送缓存检查", sections: [{ title: "无法检查", text: "文件超过 WQ 检查器的读取上限。未解析、未输出任何原始内容。" }] };
  }
  const plist = input.plist;
  if (!plist || typeof plist !== "object" || Array.isArray(plist)) {
    return { title: "抖音推送缓存检查", sections: [{ title: "无法检查", text: "请选择抖音应用数据 Library/Preferences 下的偏好设置 plist 文件。" }] };
  }
  const own = (key) => Object.prototype.hasOwnProperty.call(plist, key);
  const rows = [];
  const tokenKey = "BDUGPushDeviceToken";
  let tokenStatus = "未找到（不证明当前进程没有令牌）";
  if (own(tokenKey)) {
    const token = plist[tokenKey];
    tokenStatus = typeof token === "string" ? (token.length ? "存在（内容隐藏）" : "存在但为空") : "存在，类型异常（内容隐藏）";
  }
  rows.push({ label: "推送令牌缓存", value: tokenStatus });
  const versionKey = "BDUGPushVersionCodeKey";
  let versionStatus = "未找到";
  if (own(versionKey)) {
    const version = plist[versionKey];
    if (typeof version === "string" && /^[0-9]+(?:\.[0-9]+)*$/.test(version) && version.length <= 24) versionStatus = version;
    else if (typeof version === "number" && Number.isSafeInteger(version) && version >= 0) versionStatus = String(version);
    else versionStatus = "存在但格式不匹配（内容隐藏）";
  }
  rows.push({ label: "推送 SDK 版本标识（非抖音版本）", value: versionStatus });
  const timeKey = "BDUGPushUploadTokenTimestampKey";
  let timeStatus = "未找到";
  if (own(timeKey)) {
    const time = plist[timeKey];
    if (typeof time === "number" && Number.isFinite(time) && time > 0 && time <= 4102444800) timeStatus = new Date(time * 1000).toISOString() + "（UTC）";
    else timeStatus = "存在但不是合理的 Unix 秒数（内容隐藏）";
  }
  rows.push({ label: "缓存上传时间", value: timeStatus });
  const any = own(tokenKey) || own(versionKey) || own(timeKey);
  return {
    title: "抖音推送缓存检查",
    sections: [
      { title: "推送缓存", rows },
      { title: "结论边界", text: (any ? "发现已确认的 SDK 缓存键。" : "未找到已确认的 SDK 缓存键，可能是文件选择不正确、缓存未落盘或 SDK 未保存。") + "\n" + warning }
    ]
  };
}
