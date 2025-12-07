- filePath: entry/src/main/ets/pages/Index.ets
  code: |
    59		  getWeather(force?: boolean) {
    60		    this.isRefreshing = true;
    61		    promptAction.showToast({ message: $r('app.string.loading') })
    62		    PreferenceManager.getInstance().getLastRequestTime()
    63		      .then(lastRefreshTime => {
    64		        this.lastRefreshTime = new Date(lastRefreshTime).toTimeString();
    65		        RdbManager.getInstance()
    66		          .getAllStoredCities()
    67		          .then(cities => {
    68		            this.cities = cities;
    69		            Logger.info(TAG, "cities got", cities.length);
    70		            return ApiManager.getInstance().getCurrentLocation()
    71		          })
    72		          .then(location => {
    73		            let tempArr = [location];
    74		            this.cities = tempArr.concat(this.cities);
    75		            return PreferenceManager.getInstance().getCacheValidTime();
    76		          })
    77		          .then(cacheValidTime => {
    78		            Logger.log(TAG, "Cache valid time is:", cacheValidTime);
    79		            Logger.log(TAG, "Using cache:",!(new Date().getTime() - lastRefreshTime > cacheValidTime || force));
    80		            // 递归数据刷新函数
    81		            const loopRefresher = (index: number, useCache?: boolean) => {
    82		              if (index == this.cities.length) {
    83		                this.isRefreshing = false;
    84		                if (this.jumpToEditOnLoadingFinished) router.pushUrl({ url: 'pages/EditPage' });
    85		                if (!useCache) promptAction.showToast({ message: "刷新成功" });
    86		                return;
    87		              }
    88		              Logger.log(TAG, "loop refresher:", `${index + 1}/${this.cities.length}`);
    89		              let city = this.cities[index];
    90		              ApiManager.getInstance().qLookupCity(DataUtils.getCitySearchIdentity(city))
    91		                .then(info => {
    92		                  // 矫正缓存的城市信息
    93		                  this.cities[index].name = info[0].name;
    94		                  this.cities[index].adm1 = info[0].adm1;
    95		                  this.cities[index].adm2 = info[0].adm2;
    96		                  if (!useCache) {
    97		                    // 各城市气象警告
    98		                    ApiManager.getInstance()
    99		                      .qGetWarning(DataUtils.getCitySearchIdentity(city))
    100		                      .then(warnings => {
    101		                        if (this.warnings[index]) {
    102		                          this.warnings[index] = new LazyList(warnings);
    103		                        } else {
    104		                          this.warnings.push(new LazyList(warnings));
    105		                        }
    106		                        return RdbManager.getInstance()
    107		                          .setCache(DataUtils.getCitySearchIdentity(city), 'warnings', warnings)
    108		                          .then((): Promise<WeatherDaily[]> => {
    109		                            // 各城市每日预报
    110		                            return ApiManager.getInstance().qGetWeatherDaily(DataUtils.getCitySearchIdentity(city));
    111		                          });
    112		                      })
    113		                      .then(dailyWeather => {
    114		                        if (this.dailyWeather[index]) {
    115		                          this.dailyWeather[index] = dailyWeather;
    116		                        } else {
    117		                          this.dailyWeather.push(dailyWeather);
    118		                        }
    119		                        return RdbManager.getInstance()
    120		                          .setCache(DataUtils.getCitySearchIdentity(city), 'daily', dailyWeather)
    121		                          .then((): Promise<WeatherHourly[]> => {
    122		                            // 获取每小时预报
    123		                            return ApiManager.getInstance().qGetWeatherHourly(DataUtils.getCitySearchIdentity(city));
    124		                          });
    125		                      })
    126		                      .then(hourlyWeather => {
    127		                        if (this.hourlyWeather[index]) {
    128		                          this.hourlyWeather[index] = hourlyWeather;
    129		                        } else {
    130		                          this.hourlyWeather.push(hourlyWeather);
    131		                        }
    132		                        return RdbManager.getInstance()
    133		                          .setCache(DataUtils.getCitySearchIdentity(city), 'hourly', hourlyWeather)
    134		                          .then((): Promise<WeatherRealTime> => {
    135		                            // 获取实时天气
    136		                            return ApiManager.getInstance().qGetWeatherRealTime(DataUtils.getCitySearchIdentity(city));
    137		                          });
    138		                      })
    139		                      .then(realTimeWeather => {
    140		                        if (this.realTimeWeather[index]) {
    141		                          this.realTimeWeather[index] = realTimeWeather;
    142		                        } else {
    143		                          this.realTimeWeather.push(realTimeWeather);
    144		                        }
    145		                        RdbManager.getInstance()
    146		                          .setCache(DataUtils.getCitySearchIdentity(city), 'realtime', realTimeWeather)
    147		                          .then(() => {
    148		                            index++;
    149		                            this.lastRefreshTime = new Date().toTimeString();
    150		                            PreferenceManager.getInstance().setLastRequestTime(new Date().getTime());
    151		                            loopRefresher(index);
    152		                          });
    153		                      });
    154		                  } else {
    155		                    RdbManager.getInstance()
    156		                      .getCache(DataUtils.getCitySearchIdentity(city))
    157		                      .then(cache => {
    158		                        Logger.log(TAG, "read warning cache", cache.warnings);
    159		                        this.warnings.push(new LazyList(cache.warnings));
    160		                        Logger.log(TAG, "read daily cache", cache.daily);
    161		                        this.dailyWeather.push(cache.daily);
    162		                        Logger.log(TAG, "read hourly cache", cache.hourly);
    163		                        this.hourlyWeather.push(cache.hourly);
    164		                        Logger.log(TAG, "read realtime cache", cache.realtime);
    165		                        this.realTimeWeather.push(cache.realtime);
    166		                        index++;
    167		                        loopRefresher(index, useCache);
    168		                      })
    169		                  }
    170		                })
    171		            }
    172		            // 如果上次刷新时间离现在过短，且不是强制刷新，则从rdb读取缓存气象信息
    173		            if (!(new Date().getTime() - lastRefreshTime > cacheValidTime || force)) {
    174		              loopRefresher(0, true);
    175		            } else {
    176		              loopRefresher(0);
    177		            }
    178		          });
    179		      });
    180		  }
- filePath: libNMC/src/main/ets/Utils/DataUtils.ets
  code: |
    137		  public static getCitySearchIdentity(src: City): string {
    138		    if (src.id != '') return src.id;
    139		    return `${src.lat},${src.lon}`;
    140		  }
- filePath: libNMC/src/main/ets/api/ApiManager.ets
  code: |
    77		  public async qLookupCity(location: string) {
    78		    const res = await TaskManager.getInstance().qLookupCity(location);
    79		    return res;
    80		  }
- filePath: libNMC/src/main/ets/api/TaskManager.ets
  code: |
    120		  public async qLookupCity(location: string): Promise<City[]> {
    121		    Logger.log(TAG, "is building qLookupCity task");
    122		    const key = await PreferenceManager.getInstance().getApiKey();
    123		    const lang = await PreferenceManager.getInstance().getLanguage();
    124		    const task = new taskpool.Task(Q_ApiLookupCity, location, key, lang);
    125		    Logger.log(TAG, "task built")
    126		    let res = await taskpool.execute(task) as City[];
    127		    Logger.log(TAG, "getCity length:", res.length);
    128		    return res;
    129		  }
- filePath: libNMC/src/main/ets/api/ApiBundle.ets
  code: |
    234		export async function Q_ApiLookupCity(location: string, key: string, lang: string): Promise<City[]> {
    235		  "use concurrent"
    236		  return await new Promise<City[]>(ret => {
    237		    const req = http.createHttp();
    238		    req.request(
    239		      ApiEndpoint.Q_CITY_LOOKUP(location, key, lang),
    240		      {
    241		        method: http.RequestMethod.GET
    242		      },
    243		      (err, data) => {
    244		        Logger.info("City look up", data.result.toString())
    245		        try {
    246		          if (JSON.parse(data.result.toString())['code'] != "200") {
    247		            Logger.err("Q_ApiLookupCity", "err code:", JSON.parse(data.result.toString())['code'])
    248		            ret([]);
    249		          } else {
    250		            ret(JSON.parse(data.result.toString())['location']);
    251		          }
    252		        } catch (e) {
    253		          Logger.err("city look up", e)
    254		          ret([])
    255		        }
    256		        req.destroy();
    257		      }
    258		    )
    259		  })
    260		}
- filePath: libNMC/src/main/ets/api/ApiEndpoint.ets
  code: |
    60		  public static Q_CITY_LOOKUP(location: string, key: string, lang: string) {
    61		    let url = `${ApiEndpoint.Q_GEO_API_CITY}lookup?location=${encodeURI(location)}&key=${key}&lang=${lang}`;
    62		    Logger.log(TAG, "Q_CITY_LOOKUP CALLED", url);
    63		    return url;
    64		  }
