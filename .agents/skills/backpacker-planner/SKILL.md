---
name: Backpacker Planner
description: A skill to plan your cheapest backpacking trip across countries
---

Plan and research a feasible, cost-optimized backpacking trip for the user's requested destinations. Optimize total trip value, feasibility, and cost—not the number of countries visited. Reorder or skip destinations when that produces a materially better trip.

The report must cover:

- Route options and transportation
- A day-by-day itinerary and places to visit
- Accommodation and locally representative food costs
- Entry requirements and operational constraints
- A complete expected cost in the user's budget currency
- Booking priorities, fare ceilings, and a fallback if costs rise

Use the currency of the user's stated budget. Use USD only when no budget currency is provided.

## 1. Establish the constraints

Budget and travel duration are required. Ask for them when missing.

Also determine the details that materially affect legality, cost, or comfort:

- Origin and return destination
- Passport country and type
- Number of travellers and whether the budget is per person or for the whole group
- Exact dates or date flexibility
- Cabin-only baggage versus checked baggage
- Acceptance of dorms, airport sleeping, night buses/trains, and long connections

Ask only for missing information that materially changes the plan. If a reasonable assumption is enough to proceed, state it prominently instead of blocking. Never silently assume a passport when it changes visa requirements.

## 2. Draft route options

Provide up to three purpose-built options:

1. **Best value:** the strongest experience that fits the budget with a reserve.
2. **Cheapest:** the lowest defensible total cost, using fewer paid segments or destinations.
3. **Fallback:** a shorter route to use when fares exceed the booking ceilings.

For each option, explain the tradeoff. List requested destinations that were skipped and give a concrete reason, such as visa cost, backtracking, seasonal access, travel time, or budget impact.

Do not force every requested destination into the itinerary. Do not prescribe a route merely because it appears in an older example or travel guide.

## 3. Validate legal and operational feasibility

Validate every international segment before optimizing its price. Check:

- Entry visa, permitted stay, passport validity, and blank-page requirements
- Transit eligibility, permitted geographic areas, and entry **and exit** ports
- Required onward or third-country tickets
- Land-border re-entry, including routes that pass through a country twice
- Electronic travel authorizations, accommodation registration, and tourist taxes
- Whether the specific land border accepts foreign travellers using the intended mode
- Service direction, station, schedule, holiday suspension, and seasonal access
- Connection time, airport or terminal changes, and immigration requirements for self-transfers

A nationality being eligible for visa-free transit does not mean every city or border is included. Visa-free entry does not rule out a separate electronic authorization or registration requirement.

Verify airline stopover programmes through current terms. Check eligible city pairs, connection limits, fare-class exclusions, and reservation deadlines. State exactly whether accommodation, meals, and transfers are included. Never infer a free hotel from connection duration; budget paid accommodation unless inclusion is confirmed.

## 4. Research prices and local conditions

Use this source hierarchy:

1. Government and immigration sources for visas, authorizations, registration, and taxes
2. Airline, rail, bus, and border operators for schedules, stations, baggage, and inclusions
3. Official accommodation and attraction sites for current prices and conditions
4. Recent traveller reports, including Reddit, Caravanistan, blogs, and forums, for border delays and real operating conditions
5. OTAs and aggregators such as Trip, Booking.com, Traveloka, Tiket.com, and Skyscanner for fare discovery

Provide direct links and identify the research or fare-check date. Recent traveller reports supplement official rules; they do not override them.

For airfare:

- Search exact travel dates when possible.
- Distinguish exact-date quotes, published fare snapshots, and planning estimates.
- Never present an OTA route-page teaser as a confirmed fare for the user's dates.
- Check baggage, payment fees, connection protection, and self-transfer risk.
- Prefer airline sources for schedules and inclusions.
- When exact-date fares cannot be verified, provide a maximum acceptable booking price instead of claiming a live price.

For land transport, include realistic border and transfer time. Do not claim that a service is daily, free, or currently operating without evidence.

For accommodation, find cheap but recently reviewed hostels, guesthouses, or basic hotels in practical locations. Include tourist taxes and mandatory fees. Compare the price of a double room with two dorm beds when relevant.

For food, use locally representative prices from canteens, markets, bakeries, and small food stalls—not tourist-restaurant prices. State the assumed number and type of meals when using a particularly strict allowance.

## 5. Build the itinerary and budget

Create a day-by-day route that reconciles travel time, sightseeing, arrival times, and sleep locations. Count paid beds separately from airport, plane, bus, and train nights. Use overnight transport to save accommodation only when the user accepts it and the schedule is realistic.

Calculate the budget bottom-up:

```text
International transport
+ Overland transport
+ Local transport
+ Accommodation and accommodation taxes
+ Food
+ Visas and travel authorizations
+ Attractions
+ Connectivity and basic laundry
+ Baggage
+ Insurance
= Planned expenditure

Protected contingency: normally 7–10% or a stated minimum amount
Absolute ceiling = planned expenditure + contingency
```

Show per-person and group totals when relevant. State the exchange-rate source/date and use consistent rounding.

Do not describe a trip as affordable merely because its bare cost is below the budget. Classify the fit as **comfortable**, **tight**, or **infeasible** based on the remaining reserve. Do not allocate the contingency to optional tours during planning. If even the cheapest defensible route exceeds the budget, say so plainly.

## 6. Set booking rules and fallbacks

Finish with an action plan that includes:

- Maximum acceptable price for each major flight or expensive segment
- What to book or apply for first, and why
- Visa and electronic-authorization timing
- Train, bus, and hostel booking windows
- Optional expenses to cut first
- The point at which the traveller should switch to the fallback route

## Required report format

Present the report in this order:

1. Assumptions and research date
2. Recommended route and rationale
3. Alternative routes with duration, cost, and tradeoffs
4. Day-by-day itinerary with sleep locations
5. Transportation table: **from, to, mode, duration, cost, important caveat**
6. Accommodation targets and daily food budget by location
7. Entry requirements and administrative checklist
8. Full budget, protected reserve, and absolute ceiling
9. Skipped destinations and reasons
10. Fare ceilings, booking sequence, and fallback
11. Clickable sources

Keep the report concrete. Include free and paid places to visit, but distinguish optional paid activities from those included in the budget.

## Final quality checklist

Before answering, verify:

- [ ] Every international crossing is valid for the stated passport
- [ ] Every route segment operates in the stated direction
- [ ] Dates, holidays, seasonal conditions, and connection times are checked
- [ ] Days, nights, and paid accommodation reconcile
- [ ] Baggage, visas, authorizations, tourist taxes, and local transport are included
- [ ] Exact-date quotes are distinguished from estimates
- [ ] Budget arithmetic and currency conversions are correct
- [ ] Claims such as "free", "cheapest", and "daily" have evidence
- [ ] The remaining reserve is meaningful and unallocated
- [ ] A viable fallback exists
- [ ] The conclusion clearly states whether the budget is comfortable, tight, or infeasible

