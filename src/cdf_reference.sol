// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract CDF {
    int256 private constant wad = 1 ether;

    int256 internal constant ERFC_DOMAIN_UPPER = int256(6.24 ether);
    int256 internal constant ERFC_DOMAIN_LOWER = -ERFC_DOMAIN_UPPER;
    int256 internal constant SQRT2 = 1_414213562373095048;

    function cdf(
        int256 x,
        int256 mean,
        int256 deviation
    ) external pure returns (int256) {
        return _cdf(divWad(x - mean, deviation));
    }

    function _cdf(int256 x) private pure returns (int256) {
        return wad - ((wad * _erfc(divWad(x, SQRT2))) / 2);
    }

    function _erfc(int256 x) public pure returns (int256) {
        if (x == 0) return wad;
        if (x >= ERFC_DOMAIN_UPPER) return 0;
        if (x <= ERFC_DOMAIN_LOWER) return 2 * wad;

        int256 z = x > 0 ? x : -x;

        int256 r = evaluatePolynomial(findInterval(uint256(z)), z);

        return (x < 0) ? 2 * wad - r : r;
    }

    struct Interval {
        uint256 start;
        uint256 end;
        int256[] poly;
    }

    function evaluatePolynomial(
        int256[] memory poly,
        int256 x
    ) internal pure returns (int256) {
        int256 result = 0;
        int256 xPower = wad;
        for (int256 i = int256(poly.length - 1); i >= 0; i--) {
            result += (poly[uint256(i)] * xPower) / wad;
            xPower = (xPower * x) / wad;
        }
        return result;
    }

    function findInterval(uint256 x) internal pure returns (int256[] memory) {
        Interval[] memory intervals = new Interval[](29);

        int256[] memory poly0 = new int256[](6);
        poly0[0] = -124620041230776014;
        poly0[1] = 5948838269563002;
        poly0[2] = 374802697318461983;
        poly0[3] = 151951361675853;
        poly0[4] = -1.12838630244934578e18;
        poly0[5] = 1.00000002999258644e18;
        intervals[0] = Interval({
            start: 0,
            end: 83505277633666992,
            poly: poly0
        });

        int256[] memory poly1 = new int256[](5);
        poly1[0] = -68973542302857644;
        poly1[1] = 392951190781528111;
        poly1[2] = -2038912359998289;
        poly1[3] = -1.12825526344796592e18;
        poly1[4] = 999996933043385613;
        intervals[1] = Interval({
            start: 83505277633666992,
            end: 169659591110680736,
            poly: poly1
        });

        int256[] memory poly2 = new int256[](5);
        poly2[0] = -111918901176566153;
        poly2[1] = 421997236468903653;
        poly2[2] = -9508761661583282;
        poly2[3] = -1.12738991935200946e18;
        poly2[4] = 999958866368956909;
        intervals[2] = Interval({
            start: 169659591110680736,
            end: 259013601857933284,
            poly: poly2
        });

        int256[] memory poly3 = new int256[](6);
        poly3[0] = -65209676211287922;
        poly3[1] = -47530972399838904;
        poly3[2] = 397609095864567540;
        poly3[3] = -5194484505626826;
        poly3[4] = -1.12772482453226479e18;
        poly3[5] = 999966181674080294;
        intervals[3] = Interval({
            start: 259013601857933284,
            end: 353786078978528071,
            poly: poly3
        });

        int256[] memory poly4 = new int256[](5);
        poly4[0] = -172894674851269953;
        poly4[1] = 494461858019066163;
        poly4[2] = -42754224888745927;
        poly4[3] = -1.1204184806618389e18;
        poly4[4] = 999396209534647026;
        intervals[4] = Interval({
            start: 353786078978528071,
            end: 459990490036890169,
            poly: poly4
        });

        int256[] memory poly5 = new int256[](6);
        poly5[0] = 3030391579505701;
        poly5[1] = -191137674706458748;
        poly5[2] = 521142177917722566;
        poly5[3] = -59401980949370471;
        poly5[4] = -1.11561510878280657e18;
        poly5[5] = 998866774328912046;
        intervals[5] = Interval({
            start: 459990490036890169,
            end: 610520471007031846,
            poly: poly5
        });

        int256[] memory poly6 = new int256[](5);
        poly6[0] = -170158594131959763;
        poly6[1] = 480678240807594762;
        poly6[2] = -25270127869692281;
        poly6[3] = -1.12903590802504612e18;
        poly6[4] = 1.00088876118839166e18;
        intervals[6] = Interval({
            start: 610520471007031846,
            end: 716456553421772003,
            poly: poly6
        });

        int256[] memory poly7 = new int256[](6);
        poly7[0] = 55566142881019834;
        poly7[1] = -359055385165369761;
        poly7[2] = 737815103777307506;
        poly7[3] = -200493977237546773;
        poly7[4] = -1.06925447245321938e18;
        poly7[5] = 992718615091171271;
        intervals[7] = Interval({
            start: 716456553421772003,
            end: 814419090105124092,
            poly: poly7
        });

        int256[] memory poly8 = new int256[](6);
        poly8[0] = 66263503458682563;
        poly8[1] = -402293819511397760;
        poly8[2] = 807777341543742118;
        poly8[3] = -257140241235805385;
        poly8[4] = -1.04630379468055329e18;
        poly8[5] = 988996167462802833;

        intervals[8] = Interval({
            start: 814419090105124092,
            end: 909237147855088840,
            poly: poly8
        });

        int256[] memory poly9 = new int256[](6);
        poly9[0] = 69709748908741522;
        poly9[1] = -417705558249718151;
        poly9[2] = 835356742070047717;
        poly9[3] = -281826775434845926;
        poly9[4] = -1.03525075320949559e18;
        poly9[5] = 987015808155172196;
        intervals[9] = Interval({
            start: 909237147855088840,
            end: 1003249057611055390,
            poly: poly9
        });

        int256[] memory poly10 = new int256[](5);
        poly10[0] = -51957069543643922;
        poly10[1] = 67916068592961174;
        poly10[2] = 523160511883060380;
        poly10[3] = -1.4573493816038295e18;
        poly10[4] = 1.07552908615052017e18;
        intervals[10] = Interval({
            start: 1003249057611055390,
            end: 1097922081074652780,
            poly: poly10
        });

        int256[] memory poly11 = new int256[](5);
        poly11[0] = -21576688666498753;
        poly11[1] = -65453285515311699;
        poly11[2] = 742805742431458269;
        poly11[3] = -1.61818291461204684e18;
        poly11[4] = 1.11970994054624522e18;
        intervals[11] = Interval({
            start: 1097922081074652780,
            end: 1194843270539367610,
            poly: poly11
        });

        int256[] memory poly12 = new int256[](5);
        poly12[0] = 4991142056778848;
        poly12[1] = -192350762666514530;
        poly12[2] = 970177006310468837;
        poly12[3] = -1.79931283153696697e18;
        poly12[4] = 1.17383901178908414e18;
        intervals[12] = Interval({
            start: 1194843270539367610,
            end: 1295883359658419900,
            poly: poly12
        });

        int256[] memory poly13 = new int256[](6);
        poly13[0] = 33967022522158904;
        poly13[1] = -202908361681991884;
        poly13[2] = 315866429877815271;
        poly13[3] = 350027399540622084;
        poly13[4] = -1.42162941196703093e18;
        poly13[5] = 1.08201482907518231e18;
        intervals[13] = Interval({
            start: 1295883359658419900,
            end: 1403823997921401960,
            poly: poly13
        });

        int256[] memory poly14 = new int256[](5);
        poly14[0] = 41452947561477726;
        poly14[1] = -387624847292098780;
        poly14[2] = 1.36309280909816126e18;
        poly14[3] = -2.15135568339001032e18;
        poly14[4] = 1.29234786759497332e18;
        intervals[14] = Interval({
            start: 1403823997921401960,
            end: 1524293804966426200,
            poly: poly14
        });

        int256[] memory poly15 = new int256[](5);
        poly15[0] = 49268858427066813;
        poly15[1] = -435081996210602674;
        poly15[2] = 1.47119023389349598e18;
        poly15[3] = -2.260829092981613e18;
        poly15[4] = 1.33393863067852406e18;
        intervals[15] = Interval({
            start: 1524293804966426200,
            end: 1682904500003482670,
            poly: poly15
        });

        int256[] memory poly16 = new int256[](5);
        poly16[0] = 47830457285478868;
        poly16[1] = -425012909771359169;
        poly16[2] = 1.4447902781491658e18;
        poly16[3] = -2.23010022658702666e18;
        poly16[4] = 1.32053968582038817e18;
        intervals[16] = Interval({
            start: 1682904500003482670,
            end: 1829653268242741990,
            poly: poly16
        });

        int256[] memory poly17 = new int256[](6);
        poly17[0] = -11910891420479656;
        poly17[1] = 153923281372028550;
        poly17[2] = -803122082486271689;
        poly17[3] = 2.11878267140172146e18;
        poly17[4] = -2.83100624288042804e18;
        poly17[5] = 1.53491222025439544e18;
        intervals[17] = Interval({
            start: 1829653268242741990,
            end: 1963047649382193440,
            poly: poly17
        });

        int256[] memory poly18 = new int256[](6);
        poly18[0] = -13092298487596493;
        poly18[1] = 165366593717155453;
        poly18[2] = -847463753441230524;
        poly18[3] = 2.20470211694293697e18;
        poly18[4] = -2.91425753062440093e18;
        poly18[5] = 1.56718240812463783e18;
        intervals[18] = Interval({
            start: 1963047649382193440,
            end: 2094392778735246490,
            poly: poly18
        });

        int256[] memory poly19 = new int256[](6);
        poly19[0] = -12044202941517072;
        poly19[1] = 154302455874269273;
        poly19[2] = -800737262666187783;
        poly19[3] = 2.10601811887340516e18;
        poly19[4] = -2.81003362232668283e18;
        poly19[5] = 1.52314577963249886e18;
        intervals[19] = Interval({
            start: 2094392778735246490,
            end: 2227699873965740290,
            poly: poly19
        });

        int256[] memory poly20 = new int256[](5);
        poly20[0] = 16693572401373820;
        poly20[1] = -171805681808169426;
        poly20[2] = 668689413756477279;
        poly20[3] = -1.16754686285113722e18;
        poly20[4] = 772339093787630403;
        intervals[20] = Interval({
            start: 2227699873965740290,
            end: 2366381626835885040,
            poly: poly20
        });

        int256[] memory poly21 = new int256[](6);
        poly21[0] = -7163302960262008;
        poly21[1] = 98029234739114877;
        poly21[2] = -540942937570295780;
        poly21[3] = 1.50568742611081699e18;
        poly21[4] = -2.11567989610840552e18;
        poly21[5] = 1.20156800139507302e18;
        intervals[21] = Interval({
            start: 2366381626835885040,
            end: 2513845172700221680,
            poly: poly21
        });

        int256[] memory poly22 = new int256[](6);
        poly22[0] = -4654730001639576;
        poly22[1] = 66496111784487004;
        poly22[2] = -382358193099718664;
        poly22[3] = 1.1068278369622102e18;
        poly22[4] = -1.61398134123091057e18;
        poly22[5] = 949092201108683911;
        intervals[22] = Interval({
            start: 2513845172700221680,
            end: 2674315182539444850,
            poly: poly22
        });

        int256[] memory poly23 = new int256[](5);
        poly23[0] = 3084928794897101;
        poly23[1] = -36716653352470170;
        poly23[2] = 164547038290303311;
        poly23[3] = -329213390297632233;
        poly23[4] = 248210701723242406;
        intervals[23] = Interval({
            start: 2674315182539444850,
            end: 2853861424102088800,
            poly: poly23
        });

        int256[] memory poly24 = new int256[](6);
        poly24[0] = -1224051161771816;
        poly24[1] = 19396202545193950;
        poly24[2] = -123377887093972916;
        poly24[3] = 393917669673378263;
        poly24[4] = -631491475223548449;
        poly24[5] = 406792466769060236;
        intervals[24] = Interval({
            start: 2853861424102088800,
            end: 3062383982927256800,
            poly: poly24
        });

        int256[] memory poly25 = new int256[](5);
        poly25[0] = 402370982600247;
        poly25[1] = -5420085681136988;
        poly25[2] = 27439831066122594;
        poly25[3] = -61889720825432746;
        poly25[4] = 52482974671370607;
        intervals[25] = Interval({
            start: 3062383982927256800,
            end: 3318558906155272270,
            poly: poly25
        });

        int256[] memory poly26 = new int256[](5);
        poly26[0] = 74024296902580;
        poly26[1] = -1081798355654969;
        poly26[2] = 5936897008265884;
        poly26[3] = -14502731665446309;
        poly26[4] = 13307149210172562;
        intervals[26] = Interval({
            start: 3318558906155272270,
            end: 3666136354930059200,
            poly: poly26
        });

        int256[] memory poly27 = new int256[](6);
        poly27[0] = -5156183484420;
        poly27[1] = 106107014344385;
        poly27[2] = -873922083873472;
        poly27[3] = 3601239400850766;
        poly27[4] = -7425264638056221;
        poly27[5] = 6128793231179652;
        intervals[27] = Interval({
            start: 3666136354930059200,
            end: 4263596100597073860,
            poly: poly27
        });
        int256[] memory poly28 = new int256[](1);
        poly28[0] = 110950;
        intervals[28] = Interval({
            start: 4263596100597073860,
            end: 6240000000000000000,
            poly: poly28
        });
        for (uint256 i = 0; i < intervals.length; i++) {
            if (x >= intervals[i].start && x <= intervals[i].end) {
                return intervals[i].poly;
            }
        }
        revert("No interval found");
    }

    function mulWad(int256 x, int256 y) private pure returns (int256) {
        return (x * y) / wad;
    }

    function divWad(int256 x, int256 y) private pure returns (int256) {
        return (x * wad) / y;
    }
}
