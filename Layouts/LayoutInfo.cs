using UnityEngine;
using System.Collections;
using System.Linq;
using System.Globalization;
using System.Collections.Generic;

[System.Serializable]
public class LayoutInfo : MonoBehaviour
{
    public string Name;
    [TextArea(5, 50)]
    public string Description;
    //[Space(10)]
    //public string Nation;
    public string Tags;
    public bool SaveTimes = true;
    public int countryIndex = 0;

    public bool Tarmac = true;
    public bool Gravel = false;
    public bool Dirt = false;
    public bool Ice = false;
    public bool Snow = false;

    /// <summary>
    /// get the country list (english name)
    /// </summary>
    /// <returns></returns>
    public string[] GetCountries()
    {
        var cultures = CultureInfo.GetCultures(CultureTypes.SpecificCultures);
        var englishCountryCodes = new List<string>();
        foreach (var culture in cultures)
        {
            var region = new RegionInfo(culture.LCID);
            if (!englishCountryCodes.Contains(region.EnglishName))
            {
                englishCountryCodes.Add(region.EnglishName);
            }
        }
        englishCountryCodes.Sort();
        return englishCountryCodes.ToArray();
    }

    /// <summary>
    /// obtain the two letter ISO region name of the state
    /// </summary>
    /// <param name="lowercase"></param>
    /// <returns></returns>
    public string GetCountryCode(bool lowercase = false)
    {
        var countries = GetCountries();
        if (countries.Length >= countryIndex)
        {
            string englishName = countries[countryIndex];
            var cultures = CultureInfo.GetCultures(CultureTypes.SpecificCultures);
            foreach (var culture in cultures)
            {
                var region = new RegionInfo(culture.LCID);
                if (region.EnglishName == englishName)
                {
                    if (lowercase)
                    {
                        return region.TwoLetterISORegionName;
                    }
                    else
                    {
                        return region.TwoLetterISORegionName.ToLower();
                    }
                }
            }
        }
        return "";
    }

    /// <summary>
    /// obtain the list of surfaces
    /// </summary>
    /// <returns></returns>
    public string GetSurfaces()
    {
        var surfaces = new List<string>();
        if (Tarmac) surfaces.Add("tarmac");
        if (Gravel) surfaces.Add("gravel");
        if (Dirt) surfaces.Add("Dirt");
        if (Ice) surfaces.Add("ice");
        if (Snow) surfaces.Add("snow");

        if (surfaces.Count == 0) surfaces.Add("tarmac");
        return string.Join(",", surfaces.ToArray());
    }
}



