return {
    id = 'KoreaKarthus',
    name = 'Korea Karthus',
    flag = {
        text = 'Korea Script',
        color = {
            text = 0xFFffffff,
            background1 = 0x803199d8,
            background2 = 0x800c3d5a,
        },
    },
    load = function()
        return player.charName == 'Karthus'
    end,
}
