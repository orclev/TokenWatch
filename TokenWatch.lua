if not LibStub then error("Token Watch requires LibStub") end

local lib = LibStub:GetLibrary("LibDataBroker-1.1");
local tokenIcon1 = "Interface\\Icons\\WoW_Token01";
local tokenIcon2 = "Interface\\Icons\\WoW_Token02";
local minutesOfTime = 43200;

local inactiveText = "|cFFFFFFFFG:|r |cFF888888n/a|r"; -- 0 arg
local activeText = "|cFFFFFFFFG:|r |cFF00FF00%s |cFFFFFFFFM:|r |cFF00FF00%s|r |cFFFFFFFFD:|r |cFF00FF00%s|r"; -- 3 arg, price, per minute, duration
local market = CreateFrame("frame");
local datamarket = lib:NewDataObject("Token Watch", { type = "data source", text = inactiveText, icon = tokenIcon2 });

local function MarketPriceUpdated(self, event, ...)
	if event == "TOKEN_MARKET_PRICE_UPDATED" then
		local result = ...;
		self.marketPriceAvailable = result == LE_TOKEN_RESULT_SUCCESS;
		if (result == LE_TOKEN_RESULT_ERROR_DISABLED) then
			-- self.disabled = true;
		end
		if (self.marketPriceAvailable) then
			self.price, self.duration = C_WowTokenPublic.GetCurrentMarketPrice();
			if (WowToken_IsWowTokenAuctionDialogShown()) then
				self.price = C_WowTokenPublic.GetGuaranteedPrice();
			end
		else
			self.unavailable = true;
		end
	end
end

local function UpdateDisplay(self, t)
	if (self.marketPriceAvailable) then
		local timeToSellString = _G[("AUCTION_TIME_LEFT%d_DETAIL"):format(self.duration)];
		local goldPerMinute = self.price / minutesOfTime;
		datamarket.text = format(activeText, GetMoneyString(self.price, true), GetMoneyString(goldPerMinute, true), timeToSellString);
		datamarket.icon = tokenIcon1;
		self.marketPriceAvailable = false;
	else
		if (self.unavailable) then
			datamarket.text = format(inactiveText);
			datamarket.icon = tokenIcon2;
			self.unavailable = false;
		end
	end
end

market:SetScript("OnUpdate", UpdateDisplay);
market:SetScript("OnEvent", MarketPriceUpdated);
market:RegisterEvent("TOKEN_MARKET_PRICE_UPDATED");
market.timer = C_Timer.NewTimer(5*60, function()
	C_WowTokenPublic.UpdateMarketPrice(); -- Update once every 5 minutes
end)
C_WowTokenPublic.UpdateMarketPrice();