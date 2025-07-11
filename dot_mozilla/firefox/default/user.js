// Note: if you make changes to pref.js while Firefox is running, the changes
// will be overwritten on exit. Editing this is fine, though.

// https://github.com/dm0-/installer/blob/6cf8f0bbdc91757579bdcab53c43754094a9a9eb/configure.pkg.d/firefox.sh
// https://github.com/matfurla/dotfiles/blob/master/firefox/.mozilla/user.js
// https://github.com/pyllyukko/user.js/blob/master/user.js
// https://github.com/willforde/arch-installer/blob/97dd1bdc597e85450539de62f6eb23c21865fcb7/scripts/config-firefox.sh
// https://wiki.mozilla.org/Privacy/Privacy_Task_Force/firefox_about_config_privacy_tweeks#Getting_started

// https://searchfox.org/mozilla-release/source/browser/app/profile/firefox.js
// https://searchfox.org/mozilla-release/source/modules/libpref/init/StaticPrefList.yaml
// https://searchfox.org/mozilla-release/source/modules/libpref/init/all.js

// TODO: remove existing search engines
// user_pref("browser.display.background_color", "#444");
// user_pref("browser.display.background_color.dark", "#444");

// user_pref("browser.sessionstore.privacy_level", 2);
// user_pref("extensions.pendingOperations", false); // false prevents scripted extension install?
user_pref("accessibility.browsewithcaret", true);
user_pref("accessibility.typeaheadfind.autostart", false);
user_pref("accessibility.typeaheadfind.enablesound", false);
user_pref("accessibility.typeaheadfind.flashBar", 0);
user_pref("app.normandy.enabled", false);
user_pref("app.shield.optoutstudies.enabled", false);
user_pref("beacon.enabled", false);
user_pref("browser.aboutConfig.showWarning", false);
user_pref("browser.autofocus", false);
user_pref("browser.bookmarks.defaultLocation", "unfiled");
user_pref("browser.bookmarks.editDialog.confirmationHintShowCount", 1);
user_pref("browser.bookmarks.showMobileBookmarks", false);
user_pref("browser.cache.disk.amount_written", 1505800);
user_pref("browser.cache.disk.capacity", 10240);
user_pref("browser.cache.disk.filesystem_reported", 1);
user_pref("browser.cache.disk.smart_size.enabled", false);
user_pref("browser.cache.disk.smart_size.first_run", false);
user_pref("browser.cache.disk.telemetry_report_ID", 60);
user_pref("browser.cache.frecency_experiment", 3);
user_pref("browser.cache.memory.capacity", 0);
user_pref("browser.cache.memory.enable", false);
user_pref("browser.chrome.favicons", false);
user_pref("browser.compactmode.show", true);
user_pref("browser.contentblocking.category", "custom");
user_pref("browser.contentblocking.introCount", 20);
user_pref("browser.ctrlTab.migrated", true);
user_pref("browser.ctrlTab.recentlyUsedOrder", false);
user_pref("browser.discovery.enabled", false);
user_pref("browser.display.background_color", "#282828");
user_pref("browser.display.background_color.dark", "#282828");
user_pref("browser.display.use_document_fonts", 0);
user_pref("browser.displayedE10SNotice", 4);
user_pref("browser.download.always_ask_before_handling_new_types", true);
user_pref("browser.download.autohideButton", false);
user_pref("browser.download.folderList", 2);
user_pref("browser.download.importedFromSqlite", true);
user_pref("browser.download.lastDir", "/home/joseph"); // TODO: set expected dir based on filetype
user_pref("browser.download.manager.alertOnEXEOpen", false);
user_pref("browser.download.panel.shown", true);
user_pref("browser.download.save_converter_index", 2);
user_pref("browser.download.useDownloadDir", false);
user_pref("browser.eme.ui.firstContentShown", true);
user_pref("browser.engagement.ctrlTab.has-used", true);
user_pref("browser.feeds.handler.default", "web");
user_pref("browser.feeds.showFirstRunUI", false);
user_pref("browser.formfill.enable", false);
user_pref("browser.hotfix.v20141211.applied", true);
user_pref("browser.link.open_newwindow.restriction", 0);
user_pref("browser.messaging-system.whatsNewPanel.enabled", false);
user_pref("browser.migrated-sync-button", true);
user_pref("browser.newtab.extensionControlled", true);
user_pref("browser.newtab.privateAllowed", true);
user_pref("browser.newtab.url", "about:blank");
user_pref("browser.newtabpage.activity-stream.asrouter.providers.cfr", "null");
user_pref("browser.newtabpage.activity-stream.asrouter.providers.message-groups", "null"); // biome-ignore format:x
user_pref("browser.newtabpage.activity-stream.asrouter.providers.messaging-experiments", "null"); // biome-ignore format:x
user_pref("browser.newtabpage.activity-stream.asrouter.providers.whats-new-panel", "null"); // biome-ignore format:x
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons", false); // biome-ignore format:x
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features", false); // biome-ignore format:x
user_pref("browser.newtabpage.activity-stream.discoverystream.config", "[]");
user_pref("browser.newtabpage.activity-stream.feeds.system.topstories", false);
user_pref("browser.newtabpage.activity-stream.feeds.topsites", false);
user_pref("browser.newtabpage.activity-stream.migrationExpired", true);
user_pref("browser.newtabpage.activity-stream.showSearch", false);
user_pref("browser.newtabpage.activity-stream.tippyTop.service.endpoint", "");
user_pref("browser.newtabpage.directory.ping", "");
user_pref("browser.newtabpage.directory.source", "");
user_pref("browser.newtabpage.enabled", false);
user_pref("browser.newtabpage.enhanced", false);
user_pref("browser.newtabpage.pinned", "[]");
user_pref("browser.panorama.animate_zoom", false);
user_pref("browser.panorama.experienced_first_run", true);
user_pref("browser.panorama.session_restore_enabled_once", true);
user_pref("browser.preferences.advanced.selectedTabIndex", 2);
user_pref("browser.protections_panel.infoMessage.seen", true);
user_pref("browser.proton.enabled", true); // if false, checkboxes on settings page become tiny
user_pref("browser.proton.modals.enabled", false);
user_pref("browser.reader.detectedFirstArticle", true);
user_pref("browser.rights.3.shown", true);
user_pref("browser.safebrowsing.downloads.remote.enabled", false);
user_pref("browser.safebrowsing.malware.enabled", false);
user_pref("browser.safebrowsing.phishing.enabled", false);
user_pref("browser.search.highlightCount", 2);
user_pref("browser.search.openintab", true);
user_pref("browser.search.removeEngineInfobar.enabled", true);
user_pref("browser.search.showOneOffButtons", false);
user_pref("browser.search.suggest.enabled.private", true);
user_pref("browser.search.widget.inNavBar", true); // TODO: not respected -- https://bugzilla.mozilla.org/show_bug.cgi?id=1425199, https://github.com/mozilla/iris_firefox/issues/3613#issuecomment-521021133
user_pref("browser.sessionhistory.max_entries", 10);
user_pref("browser.sessionhistory.max_total_viewers", 0);
user_pref("browser.sessionstore.interval", 300000);
user_pref("browser.sessionstore.max_serialize_back", 3);
user_pref("browser.sessionstore.max_serialize_forward", 3);
user_pref("browser.sessionstore.max_tabs_undo", 5);
user_pref("browser.sessionstore.max_windows_undo", 0);
user_pref("browser.sessionstore.restore_pinned_tabs_on_demand", true);
user_pref("browser.shell.checkDefaultBrowser", true);
user_pref("browser.shell.didSkipDefaultBrowserCheckOnFirstRun", true);
user_pref("browser.startup.homepage", "about:blank");
user_pref("browser.startup.homepage_override.mstone", "ignore");
user_pref("browser.startup.page", 3); // restore previous sessions
user_pref("browser.tabs.allowTabDetach", false); // only for native tab bar; for TST, see https://github.com/piroor/treestyletab/issues/2629#issuecomment-1027715577
user_pref("browser.tabs.closeWindowWithLastTab", false);
user_pref("browser.tabs.drawInTitlebar", false);
user_pref("browser.tabs.remote.autostart", false);
user_pref("browser.tabs.remote.autostart.2", false);
user_pref("browser.tabs.tabMaxWidth", 150);
user_pref("browser.tabs.warnOnClose", false);
user_pref("browser.tabs.warnOnOpen", false);
user_pref("browser.toolbarbuttons.introduced.pocket-button", true);
user_pref("browser.toolbars.bookmarks.visibility", "never");
user_pref("browser.topsites.migratedToRemoteSetting.id", 1);
user_pref("browser.turbo.enabled", true);
user_pref("browser.uidensity", 1);
user_pref("browser.uitour.enabled", false);
user_pref("browser.urlbar.autocomplete.enabled", false);
user_pref("browser.urlbar.clickSelectsAll", true);
user_pref("browser.urlbar.delay", 0);
user_pref("browser.urlbar.matchBuckets", "general:5,suggestion:Infinity");
user_pref("browser.urlbar.maxRichResults", 0);
user_pref("browser.urlbar.openViewOnFocus", false);
user_pref("browser.urlbar.openintab", true);
user_pref("browser.urlbar.placeholderName", "Google");
user_pref("browser.urlbar.placeholderName.private", "Google");
user_pref("browser.urlbar.quantumbar", false);
user_pref("browser.urlbar.searchSuggestionsChoice", false);
user_pref("browser.urlbar.shortcuts.bookmarks", false);
user_pref("browser.urlbar.shortcuts.history", false);
user_pref("browser.urlbar.shortcuts.tabs", false);
user_pref("browser.urlbar.showSearchSuggestionsFirst", false);
user_pref("browser.urlbar.speculativeConnect.enabled", false);
user_pref("browser.urlbar.suggest.bookmark", false);
user_pref("browser.urlbar.suggest.history", false);
user_pref("browser.urlbar.suggest.openpage", false);
user_pref("browser.urlbar.suggest.quicksuggest", false);
user_pref("browser.urlbar.suggest.quicksuggest.sponsored", false);
user_pref("browser.urlbar.suggest.searches", false);
user_pref("browser.urlbar.suggest.topsites", false);
user_pref("browser.urlbar.suggest.trending", false);
user_pref("browser.urlbar.timesBeforeHidingSuggestionsHint", 2);
user_pref("browser.urlbar.tipShownCount.tabToSearch", 2);
user_pref("browser.urlbar.trimURLs", false);
user_pref("browser.warnOnQuitShortcut", false);
user_pref("content.interrupt.parsing", true);
user_pref("content.max.tokenizing.time", 2250000);
user_pref("content.switch.threshold", 750000);
user_pref("datareporting.healthreport.uploadEnabled", false);
user_pref("devtools.aboutdebugging.collapsibilities.processes", false);
user_pref("devtools.chrome.enabled", true);
user_pref("devtools.command-button-rulers.enabled", true);
user_pref("devtools.command-button-scratchpad.enabled", true);
user_pref("devtools.command-button-screenshot.enabled", true);
user_pref("devtools.debugger.remote-enabled", true);
user_pref("devtools.everOpened", true);
user_pref("devtools.gcli.hideIntro", true);
user_pref("devtools.inspector.three-pane-first-run", false);
user_pref("devtools.onboarding.telemetry.logged", true);
user_pref("devtools.responsiveUI.currentPreset", "320x480");
user_pref("devtools.responsiveUI.rotate", false);
user_pref("devtools.screenshot.audio.enabled", false);
user_pref("devtools.selfxss.count", 5);
user_pref("devtools.theme", "dark");
user_pref("devtools.toolbox.footer.height", 324);
user_pref("devtools.toolbox.host", "window");
user_pref("devtools.toolbox.selectedTool", "netmonitor");
user_pref("devtools.toolbox.sidebar.width", 1009);
user_pref("devtools.toolbox.tabsOrder", "netmonitor,storage,inspector,webconsole,jsdebugger,styleeditor,performance,memory,accessibility,application"); // biome-ignore format:x
user_pref("devtools.toolsidebar-height.inspector", 350);
user_pref("devtools.toolsidebar-width.inspector", 1280);
user_pref("devtools.toolsidebar-width.inspector.splitsidebar", 640);
user_pref("devtools.webconsole.filter.csserror", false);
user_pref("devtools.webconsole.input.editorOnboarding", false);
user_pref("devtools.webconsole.timestampMessages", true);
user_pref("devtools.webextensions.https-everywhere-eff@eff.org.enabled", true);
user_pref("distribution.iniFile.exists.value", true);
user_pref("doh-rollout.balrog-migration-done", true);
user_pref("doh-rollout.doneFirstRun", true);
user_pref("dom.apps.reset-permissions", true);
user_pref("dom.battery.enabled", false);
user_pref("dom.event.clipboardevents.enabled", false);
user_pref("dom.mozApps.used", true);
user_pref("dom.popup_allowed_events", "change click dblclick mouseup notificationclick reset submit touchend keypress"); // biome-ignore format:x
user_pref("dom.private-attribution.submission.enabled", false); // https://blog.privacyguides.org/2024/07/14/mozilla-disappoints-us-yet-again-2/
user_pref("dom.security.https_only_mode", true);
user_pref("e10s.rollout.cohort", "optedIn");
user_pref("e10s.rollout.cohortSample", "0.537958");
user_pref("experiments.activeExperiment", false);
user_pref("extensions.activeThemeID", "firefox-compact-dark@mozilla.org");
user_pref("extensions.e10s.rollout.blocklist", "");
user_pref("extensions.e10s.rollout.hasAddon", true);
user_pref("extensions.e10s.rollout.policy", "50allmpc");
user_pref("extensions.e10sBlockedByAddons", false);
user_pref("extensions.e10sMultiBlockedByAddons", false);
user_pref("extensions.etp_search_volume_study.channel_cohort_prefix", "c");
user_pref("extensions.fxmonitor.firstAlertShown", true);
user_pref("extensions.getAddons.databaseSchema", 6);
user_pref("extensions.incognito.migrated", true);
user_pref("extensions.pictureinpicture.enable_picture_in_picture_overrides", true); // biome-ignore format:x
user_pref("extensions.pocket.enabled", false);
user_pref("extensions.privatebrowsing.notification", true);
user_pref("extensions.sidebar-button.shown", true);
user_pref("extensions.signer.hotfixed", true);
user_pref("extensions.tabgroups.animateZoom", false);
user_pref("extensions.tabgroups.displayMode", "classic");
user_pref("extensions.tabgroups.lastPrefPane", "paneTabGroups");
user_pref("extensions.tabgroups.message", 0);
user_pref("extensions.tabgroups.migratedKeysets", true);
user_pref("extensions.tabgroups.migratedPrefs", true);
user_pref("extensions.tabgroups.migratedWidget", true);
user_pref("extensions.tabgroups.pageAutoChanged", true);
user_pref("extensions.tabgroups.userNoticedTabOnUpdates", true);
user_pref("extensions.ublock0.cloudStorage.myFiltersPane", "");
user_pref("extensions.ublock0.cloudStorage.myRulesPane", "");
user_pref("extensions.ublock0.cloudStorage.tpFiltersPane", "");
user_pref("extensions.ublock0.cloudStorage.whitelistPane", "");
user_pref("extensions.ublock0.collapseGroup7", "y");
user_pref("extensions.ublock0.dashboardLastVisitedPane", "1p-filters.html");
user_pref("extensions.ublock0.document-blocked-expand-url", "true");
user_pref("extensions.ublock0.popupFirewallPane", "true");
user_pref("extensions.ublock0.shortcuts.launch-element-picker", "");
user_pref("extensions.ublock0.shortcuts.launch-element-zapper", "");
user_pref("extensions.ublock0.shortcuts.launch-logger", "");
user_pref("extensions.ui.dictionary.hidden", true);
user_pref("extensions.ui.experiment.hidden", true);
user_pref("extensions.ui.extension.hidden", false);
user_pref("extensions.ui.locale.hidden", true);
user_pref("extensions.ui.plugin.hidden", false);
user_pref("extensions.unifiedExtensions.enabled", false); // FF 109
user_pref("extensions.webcompat.enable_picture_in_picture_overrides", true);
user_pref("extensions.webcompat.enable_shims", true);
user_pref("extensions.webcompat.perform_injections", true);
user_pref("extensions.webcompat.perform_ua_overrides", true);
user_pref("extensions.webextensions.restrictedDomains", "");
user_pref("extensions.wrtranslator.firstexec", false);
user_pref("extensions.wrtranslator.language", "fr-en");
user_pref("findbar.highlightAll", true);
user_pref("fission.experiment.max-origins.qualified", false);
user_pref("font.default.x-western", "sans-serif");
user_pref("font.internaluseonly.changed", false);
user_pref("font.language.group", "x-western");
user_pref("font.minimum-size.x-western", 13); // no effect?
user_pref("font.name.monospace.ja", "Source Han Sans JP");
user_pref("font.name.monospace.x-western", "Source Code Pro");
user_pref("font.name.sans-serif.ja", "Source Han Sans JP");
user_pref("font.name.sans-serif.x-western", "Inter"); // TODO: pacman install = Inter Variable?
user_pref("font.name.serif.ja", "Source Han Sans JP");
user_pref("font.name.serif.x-western", "Source Serif 4"); // native reader ignores these settings!
user_pref("full-screen-api.warning.timeout", 0);
user_pref("gecko.handlerService.migrated", true);
user_pref("gecko.mstone", "48.0.2");
user_pref("general.autoScroll", true);
user_pref("general.smoothScroll.mouseWheel.durationMaxMS", 150);
user_pref("general.smoothScroll.mouseWheel.durationMinMS", 75);
user_pref("general.warnOnAboutConfig", false);
user_pref("image.mem.max_decoded_image_kb", 512000);
user_pref("intl.accept_languages", "en,ja");
user_pref("intl.charset.detector", "ja_parallel_state_machine");
user_pref("javascript.options.jit.chrome", true);
user_pref("keyword.URL", "https://duckduckgo.com/?t=lm&q="); // no effect?
user_pref("layers.acceleration.force-enabled", true);
user_pref("lightweightThemes.isThemeSelected", false);
user_pref("lightweightThemes.persisted.footerURL", false);
user_pref("lightweightThemes.persisted.headerURL", false);
user_pref("lightweightThemes.usedThemes", "[]");
user_pref("media.benchmark.vp9.fps", 111);
user_pref("media.eme.enabled", true);
user_pref("media.gmp-gmpopenh264.abi", "x86_64-gcc3");
user_pref("media.gmp-gmpopenh264.enabled", false);
user_pref("media.gmp-widevinecdm.abi", "x86_64-gcc3");
user_pref("media.navigator.enabled", false);
user_pref("media.peerconnection.enabled", false);
user_pref("media.peerconnection.ice.default_address_only", true);
user_pref("media.peerconnection.ice.no_host", true);
user_pref("media.videocontrols.picture-in-picture.video-toggle.enabled", false);
user_pref("mousewheel.min_line_scroll_amount", 40);
user_pref("network.IDN_show_punycode", true);
user_pref("network.cookie.cookieBehavior", 1);
user_pref("network.cookie.prefsMigrated", true);
user_pref("network.dns.disablePrefetch", true);
user_pref("network.http.max-connections", 48);
user_pref("network.http.max-connections-per-server", 16);
user_pref("network.http.max-persistent-connections-per-proxy", 16);
user_pref("network.http.max-persistent-connections-per-server", 8);
user_pref("network.http.pipelining", true);
user_pref("network.http.pipelining.maxrequests", 8);
user_pref("network.http.proxy.pipelining", true);
user_pref("network.http.referer.XOriginPolicy", 2);
user_pref("network.http.referer.XOriginTrimmingPolicy", 2);
user_pref("network.http.request.max-start-delay", 0);
user_pref("network.http.speculative-parallel-limit", 0);
user_pref("network.predictor.cleaned-up", true);
user_pref("network.predictor.enabled", false);
user_pref("network.prefetch-next", false);
user_pref("network.protocol-handler.warn-external.apt", true);
user_pref("network.protocol-handler.warn-external.apt+http", true);
user_pref("network.proxy.type", 2);
user_pref("network.trr.blocklist_cleanup_done", true);
user_pref("nglayout.initialpaint.delay", 0);
user_pref("pdfjs.defaultZoomValue", "page-fit");
user_pref("pdfjs.enableScripting", false);
user_pref("pdfjs.enabledCache.initialized", true);
user_pref("pdfjs.enabledCache.state", true);
user_pref("pdfjs.previousHandler.alwaysAskBeforeHandling", true);
user_pref("pdfjs.previousHandler.preferredAction", 4);
user_pref("pdfjs.sidebarViewOnLoad", 2);
user_pref("pdfjs.spreadModeOnLoad", 1);
user_pref("places.history.enabled", false);
user_pref("places.history.expiration.transient_current_max_pages", 112348);
user_pref("plugin.disable_full_page_plugin_for_types", "application/pdf");
user_pref("plugin.expose_full_path", true);
user_pref("plugin.importedState", true);
user_pref("plugin.state.flash", 0);
user_pref("plugin.state.java", 0);
user_pref("plugins.ctprollout.cohort", "early-adopter-disabled");
user_pref("pref.browser.language.disable_button.down", false);
user_pref("pref.browser.language.disable_button.remove", false);
user_pref("pref.browser.language.disable_button.up", false);
user_pref("pref.downloads.disable_button.edit_actions", false);
user_pref("pref.general.disable_button.default_browser", false);
user_pref("pref.privacy.disable_button.change_blocklist", false);
user_pref("pref.privacy.disable_button.cookie_exceptions", false);
user_pref("pref.privacy.disable_button.view_cookies", false);
user_pref("pref.privacy.disable_button.view_passwords", false);
user_pref("pref.privacy.disable_button.view_passwords_exceptions", false);
user_pref("print.print_footerleft", "");
user_pref("print.print_footerright", "");
user_pref("print.print_headerleft", "");
user_pref("print.print_headerright", "");
user_pref("privacy.clearOnShutdown.cookies", false);
user_pref("privacy.clearOnShutdown.downloads", true);
user_pref("privacy.clearOnShutdown.history", false);
user_pref("privacy.clearOnShutdown.sessions", false);
user_pref("privacy.donottrackheader.enabled", true);
user_pref("privacy.firstparty.isolate", true);
user_pref("privacy.history.custom", true);
user_pref("privacy.popups.showBrowserMessage", false);
user_pref("privacy.purge_trackers.date_in_cookie_database", "0");
user_pref("privacy.resistFingerprinting.block_mozAddonManager", true);
user_pref("privacy.sanitize.didShutdownSanitize", true);
user_pref("privacy.sanitize.migrateClearSavedPwdsOnExit", true);
user_pref("privacy.sanitize.migrateFx3Prefs", true);
user_pref("privacy.sanitize.sanitizeOnShutdown", true);
user_pref("privacy.socialtracking.notification.counter", 1);
user_pref("privacy.socialtracking.notification.enabled", false);
user_pref("privacy.trackingprotection.enabled", true);
user_pref("privacy.trackingprotection.introCount", 20);
user_pref("privacy.userContext.enabled", true);
user_pref("privacy.userContext.extension", "tridactyl.vim.betas@cmcaine.co.uk");
user_pref("privacy.userContext.longPressBehavior", 2);
user_pref("privacy.userContext.ui.enabled", true);
user_pref("reader.color_scheme", "dark");
user_pref("reader.content_width", 9);
user_pref("reader.font_size", 8);
user_pref("reader.font_type", "serif");
user_pref("reader.line_height", 6);
user_pref("security.dialog_enable_delay", 0);
user_pref("security.sandbox.content.level", 3);
user_pref("services.blocklist.clock_skew_seconds", 0);
user_pref("services.settings.clock_skew_seconds", 0);
user_pref("sidebar.animation.duration-ms", 0);
user_pref("sidebar.animation.enabled", false);
user_pref("sidebar.animation.expand-on-hover.duration-ms", 0);
user_pref("sidebar.backupState", '{"panelOpen":false,"launcherWidth":240,"expandedLauncherWidth":240,"launcherExpanded":true,"launcherVisible":true}'); // biome-ignore format:x
user_pref("sidebar.expandOnHover", true);
user_pref("sidebar.main.tools", "aichat"); // if "", reverts to default
user_pref("sidebar.verticalTabs", true); // 136 -- https://support.mozilla.org/en-US/kb/use-sidebar-access-tools-and-vertical-tabs
user_pref("sidebar.visibility", "expand-on-hover");
user_pref("signon.importedFromSqlite", true);
user_pref("signon.usage.hasEntry", true);
user_pref("storage.vacuum.last.index", 1);
user_pref("svg.context-properties.content.enabled", true);
user_pref("toolkit.cosmeticAnimations.enabled", false);
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true); // important: userChrome.css
user_pref("toolkit.scrollbox.clickToScroll.scrollDelay", 0);
user_pref("toolkit.scrollbox.smoothScroll", false);
user_pref("toolkit.telemetry.pioneer-new-studies-available", true);
user_pref("toolkit.telemetry.reportingpolicy.firstRun", false);
user_pref("tridactyl.unfixedamo_removed", true);
user_pref("ui.prefersReducedMotion", 1);
user_pref("ui.submenuDelay", 0);
user_pref("view_source.wrap_long_lines", true);
user_pref("webgl.disabled", true);
user_pref("widget.content.allow-gtk-dark-theme", true);
user_pref("xpinstall.signatures.required", false);
user_pref("xpinstall.whitelist.add", "");
user_pref("xpinstall.whitelist.add.180", "");
user_pref("xpinstall.whitelist.required", false);

// https://support.mozilla.org/en-US/questions/1423347
// https://support.mozilla.org/en-US/questions/1296613
user_pref("browser.startup.couldRestoreSession.count", -1);
user_pref("trailhead.firstrun.branches", "nofirstrun-empty");
user_pref("browser.aboutwelcome.enabled", false);
// https://github.com/Carm01/Mozilla.cfg/blob/07118683d0ef3037a5977a5e2f34e92c297f3b4d/mozilla.cfg#L29
user_pref("datareporting.policy.dataSubmissionPolicyBypassNotification", true);
user_pref("browser.ml.chat.enabled", false);
user_pref("reader.parse-on-load.enabled", false);
user_pref("media.webspeech.synth.enabled", false);
user_pref("browser.translations.automaticallyPopup", false);
user_pref("browser.translations.enable", false);
user_pref("browser.translations.panelShown", false);

// none of these work
// user_pref("browser.search.defaultenginename", "DuckDuckGo");
user_pref("browser.search.defaultenginename", "data:text/plain,browser.search.defaultenginename=DuckDuckGo"); // biome-ignore format:x
user_pref("browser.search.order.1", "DuckDuckGo");
user_pref("browser.search.selectedEngine", "DuckDuckGo");
user_pref("keyword.URL", "https://duckduckgo.com/?q=");
