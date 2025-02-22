
## Changelog

-   2020-04-12 - Georgia started separating non-state residents from
    their patient counts. Neither The New York Times nor Georgia
    adjusted the counts prior to the change. Without an adjustment, it
    destroyed the coherence of the data, so I’ve replaced them with
    South Carolina in the daily growth rate chart.

-   2020-05-07 - The New York Times
    [decided](https://github.com/nytimes/covid-19-data/blob/master/PROBABLE-CASES-NOTE.md)
    to combine “probable” and “confirmed” positive cases and deaths in
    their datesets so that the data would remain consistent across all
    states. I think it provides a more accurate description of what’s
    going, so I’ve decided to keep their data source and discard Indiana
    State Department of Health’s (ISDH). The ramification is that many
    charts’ data will be a day late. Hopefully ISDH will opensource
    their probable cases and probable deaths, so the charts can return
    to being up-to-date.  

-   2020-05-11 - The calculation of the rate for the Positive Test Rate
    chart was changed from using total counts to a rolling calculation
    over a 3 day windows. The interpretation has also changed based on
    the Johns Hopkins
    [article](https://coronavirus.jhu.edu/testing/testing-positivity).  

-   2020-05-12 - Replaced the chart that compares daily growth rates and
    doubling times of states with similar population densities with a
    social distancing chart that uses Google Maps data. The daily growth
    rates chart ceased being interesting as doubling times and rates
    have pretty much plateaued. Also, I don’t want to present too many
    charts at once as it might create some information overload. If a
    second or third wave happens, then this chart might return.  

-   2020-05-26 - Changed wording of the Hospitalizations - Ventilators -
    ICU Beds chart title. I misinterpreted the description of the
    hospitalizations data. I thought I was calculating the daily number
    of people being admitted to the hospital for COVID-19 when it was
    the change in the present count of people hospitalized for COVID-19.
    It’s still relevant because the governor’s speech used present count
    and not daily admittance as a guideline anyways. Apologees though.  

-   2020-05-29 - County chart - Instead of using all the historic data
    to calculate average daily growth rates, I’m switching to only using
    data over the past 2 weeks which will make the estimates more
    sensitive to outbreaks if they happen.  

-   2020-06-11 - Replaced the Apple Mobility chart with an OpenTables
    chart. Driving levels seem to have returned to pre-COVID levels, and
    with reopening stages well underway, it’ll be more useful to monitor
    how industries, like restaurants, hard-hit by COVID are recovering.
    The Apple Mobility chart will likely return if a second wave emerges
    though.  

-   2020-06-13 - Changed the range and scale of the axes on the
    daily-positives-cumulative-policy chart. The data trend was no
    longer exponential so the log scaling isn’t really needed and it was
    bunching up the data points. At this point in the pandemic, what
    happens after the reopening stages is salient, so I’ve started the
    data at the point a couple weeks before stage 2.  

-   2020-06-21 - Switched to the rt.live model for R<sub>e</sub>. I
    haven’t been confortable with estimate I’ve been using for awhile.
    Their estimate along with their uncertainty range look more
    reasonable than the one I was using before. They haven’t published
    their code yet, so I haven’t been able to dig into it too much. But
    the [faq](https://rt.live/faq) gives some hints to what they’re
    doing, and it seems sound.  

-   2020-07-08 - Daily positive rate - During a
    [briefing](https://twitter.com/i/broadcasts/1ypKdwaqLegxW) I watched
    with Gov. Holcomb and Dr. Box, it was pretty clear that they pay
    close attention to positivity rates and use a seven day window to
    calculate theirs, so I’m switching my calculation window to 7 days.
    A 5% percent target was also emphasized by Dr. Box, so also changing
    my shaded region to a range from 0% - 5%.  

-   2020-08-17 - Daily positive rate - I calculate the rate for all the
    data I have, but I don’t display the most recent two I’ve
    calculated, because there isn’t enough data to give a reasonable
    rate. I’ve decided remove another daily rate. So the last two rates
    that I calculate won’t be displayed; for the same reason. The lack
    of data makes these rates misleading, and some people don’t read the
    chart descriptions.  

-   2020-09-18 - Daily positive rate, Median Age Weekly Cases and Tests,
    COVIDcast MSA Positivity - For about a month, ISDH’s dashboard has
    shown and Dr. Box has been referencing a much lower positivity rate,
    but haven’t included the testing data used to calculate that rate at
    Indiana Data Hub. Not sure when COVID_TESTS_ADMINISTRATED \[sic\]
    was added to the county-level dataset, but it’s there now and I’ll
    be using that field to calculate my positivity rate.

    The previous field I used for test counts only counted tests for
    unique individuals (i.e. no repeat tests of individuals were
    included). If a person was tested in March and then again in July,
    each test should be recorded for that month in order for the
    positivity rate to more accurately reflect the state of testing and
    viral spread. This new field includes these repeat tests and
    substantially increases the test counts which therefore lowers the
    positivity rate as a result.

    COVID_TESTS_ADMINISTRATED is an improvement, but it’s not ideal and
    will give a **deflated** positivity rate. This new field
    unfortunately includes *daily* repeated tests when the count of
    individuals tested per day is what is actually needed. These
    COVID-19 diagnostic tests are not perfectly accurate, so false
    positive and false negative testing results occur. To increase the
    probability of getting a “true” test result, multiple tests for the
    same person on the same day may occur. But given that these PCR
    diagnostic tests are pretty expensive and information I’ve received
    from people who have been tested, I’m not inclined to think multiple
    *daily* tests of the same individual occur that often. With cheaper
    tests now developed, maybe this becomes a larger issue in the future
    though. Some states are currently providing a count of individuals
    tested per day which is named, “test encounters.” A more detailed
    discussion of this test count is discussed in a
    [post](https://covidtracking.com/blog/counting-covid-19-tests) over
    at The COVID Tracking Project. Hopefully, ISDH will start using test
    encounters in the near future.

-   2020-12-20 - Hospitals page, Local Hospital Capacity - The number of
    available beds used in the calculations is fluid, because only the
    number of fully staffed beds is reported. Therefore, if a hospital
    suffers from personnel shortages, the number of available beds
    reported by that hospital will decrease.

    When any of the counts for any of the data fields is below four, the
    true count is obscured by the CDC. This is due to the concern that
    this data combined with other publicly available data might be used
    violate patient privacy. Anytime that 80% of a hospital’s data used
    in a calculation was missing and/or obscured, I decided not to
    perform the calculation for that hospital (empty table cell). If
    some of the data (but less than 80%) were obsured, then I
    substituted a “2” for the obscured value and proceded with the
    calculation.

-   2020-12-25 - Hospitals page, State Mortality Rate, Staffing, and
    Admissions - The hospitals deaths and admissions were scraped from
    the Regenstrief dashboard, but I did check the robots.txt file and
    followed the rules therein. It’s my first time scraping a Tableau
    dashboard, so I’m not a hundred percent about the data. It checks
    out visually with the dashboard sometimes and in some places, but
    not others. I only collect it twice a day, so maybe the data is
    being updated before or after I’m collecting. The tableau worksheets
    and variable names from where I’m getting the data all look right,
    so I think I’m getting the right stuff.

    The HHS staffing data only includes **reporting** hospitals, but for
    the time period I’m looking at and foreseeable future I don’t
    anticipate much non-response bias. The last time I looked only
    around 3 hospitals weren’t reporting their staff shortage numbers.
    That seemed to be the case at least over the last couple months. And
    looking at the “Local Hospital Capacity” table there seems to be
    good response there as well. So this isn’t something I’ll be
    monitoring too closely.

    I chose 14 day rolling window for the mortality rate calculation
    because the average hospital length of stay for all age groups
    didn’t exceed that length on the Regenstrief dashboard. So,
    averaging over a 2-week period should be representative. For the
    other two calculations, a seven day window seems be a good number to
    smooth out reporting irregularities, and I think that’s the only
    concern I have with those samples.
