Pointshop2.AddEquipmentSlot( "Stattrak", function( item )
	--Check if the item is a trail
	return instanceOf( Pointshop2.GetItemClassByPrintName( "Stattrak Modul" ), item )
end, 1 )
