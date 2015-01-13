/*----------------------------------------------------------
--
-- Copyright (C) 2012 Sanpolo Co.LTD
-- http://www.spolo.org
--
--  This file is part of the UGE(Uniform Game Engine).
--  Copyright (C) by SanPolo Co.Ltd. 
--  All rights reserved.
--
--  See http://uge.spolo.org/ for more information.
--
--  SanPolo Co.Ltd
--  http://uge.spolo.org/  sales@spolo.org uge-support@spolo.org

--
------------------------------------------------------------
*/

include "config.ms"
include "utils.ms"

-- *********************************************************************
-- *********************************************************************
--
--                              check 1
--
-- *********************************************************************
-- *********************************************************************

--�жϴ����ı��ε���abc
fn checkMesh delFlag =
(
	local bSuc = true
	
	disableSceneRedraw()
	
    local arr_model = #() 
    local errorMsg = stringstream ""
    for igeo in geometry do
    (
        local a = classof igeo
        if a != Editable_Poly then converttopoly igeo
        local num_faces = polyop.getNumFaces igeo	
        for f = 1 to num_faces do(
            local num_face_verts = polyop.getFaceDeg igeo f
            if num_face_verts > 4 then 
            (
				format "%\n" igeo.name to:errorMsg
                append arr_model igeo
            )
        )
    )
	
    if (errorMsg as String) != "" do
	(
		createLevelB 13 errorMsg
		
		if delFlag then(
			delete arr_model                    
		)
		
		bSuc = false
	)
	
	enableSceneRedraw()
	
	logtimer "checkMesh() finish"
	
	return bSuc
)
/**
 * check if object not supported by SPP exists.
 */
fn checkUnsupportedObject delFlag =
(
	local bSuc = true
	
	disableSceneRedraw()
	
	local errorinfo = stringstream ""
	local arrdel = #()
	
	for iobj in objects do(
		if classof iobj == Particle_View then
		(
			append arrdel iobj
			format "Particle_View:%\n" iobj.name to:errorinfo
		)
		--��Ϊvrayfur���͵�ģ�͵���x�ļ��������ɾ��Ϊ�����������İ�
		if classof iobj == VRayFur then
		(
			append arrdel iobj
			format "VRayFur:%\n" iobj.name to:errorinfo
		)
	)
	
	if (errorinfo as string) != "" do
	(
		bSuc = false
		
		-- create log contains error msg.
		createLevelB 21 errorinfo
		
		clearselection()
		-- delete these shit when scenetool.
		if delFlag == true do
		(
			delete arrdel
		)
	)
	
	enableSceneRedraw()
	
	logtimer "checkUnsupportedObject() finish"
	
	return bSuc
)

/**
 * @brief check HUD plant cross.
 * @param selFlag -- true to select first, false to check by name "plant*".
 */
fn ckHudFaceCross selFlag =
(
	local bSuc = true
	
	disableSceneRedraw()
	
	local arrmesh = #()
	
	if(selFlag) then
	(
		-- first select mesh, then check
		if(selection.count > 1) then
		(
			--arrmesh = selection as array
			try(
				if(iobj.numverts == 4) and (iobj.numfaces < 3) then
				(
					append arrmesh iobj
				)
			)catch()
		)
		else
		(
			messagebox "������ѡ������plantģ��"
			return false
		)
	)
	else
	(
		-- check all "plant*" mesh.
		for iobj in geometry do 
		(
			if(matchPattern iobj.name pattern:("plant*") ignoreCase:false) then 
			(
				try(
					if(iobj.numverts == 4) and (iobj.numfaces < 3) then
					(
						append arrmesh iobj
					)
				)catch()
			)
		)
	)
	struct AABB3 (name, radius, center)
	local arrMeshAABB = #()
	for obj in arrmesh do
	(
		--sbj = AABB3
		minobj = obj.min
		maxobj = obj.max
		minobj.z = 0
		maxobj.z = 0
		dim = distance minobj maxobj
		dim = dim/2
		sbj = AABB3 name:(obj.name) radius:(dim/2) center:((minobj + maxobj)/2)
		append arrMeshAABB sbj
	)
	
	local str = stringstream ""
	cnt = arrMeshAABB.count
	for i = 1 to cnt do
	(
		if cnt > 1 then
		(
			for j = (i+1) to cnt do
			(
				if not(computeRadius arrMeshAABB[i] arrMeshAABB[j])then
				(
					format "%��%�ľ���̫��\n" ((arrMeshAABB[i].name) as String) ((arrMeshAABB[j].name) as String) to:str
				)
			)
		)
		
	)
	
	if(str != "")then
	(
		createLevelB 12 str
		bSuc = false
	)
	
	enableSceneRedraw()
	
	logtimer "ckHudFaceCross() finish"
	
	return bSuc
)

/**
 * check small mesh and delete it
 */
fn ckSmallMesh delFlag =
(
	local bSuc = true
	
	disableSceneRedraw()
	
	local errMesh = stringstream ""
	local arrmesh = #()
	for i in geometry do
	(
		minpos = i.min
		maxpos = i.max
		lenline = distance minpos maxpos
		if(lenline < 0.05) then
		(
			format "%\n" i.name to:errMesh
			append arrmesh i
		)
	)

	if (errMesh as String) != "" do
	(
		createLevelB 11 errMesh
		
		bSuc = false
	)
	--delete small mesh
	if(delFlag)then
		delete arrmesh
	
	enableSceneRedraw()
	
	logtimer "ckSmallMesh() finish"
	
	return bSuc
)

-- Checking same name		
fn checkSameNobj delFlag msgboxFlag =
(
	local bSuc = true
	
	disableSceneRedraw()
	
	local mess = stringstream ""
	local err = 0
	
	local objsa = geometry as array
	local objsb = geometry as array
	if(objsa.count < 2) then return err
	objsb = deleteItem objsb 1
	local allSame_arr = #()
	for i=1 to objsa.count-1 do
	(
		local sameN_arr = #()
		local objaN = objsa[i].name
		for j = 1 to objsb.count do
		(
			if objsb[j] != "" do
			(
				objbN = objsb[j].name
				-- chenyang20130106
				-- Compare in case-insensitive mode.
				if (objaN as name) == (objbN as name) do
				(
					append sameN_arr objsb[j]
					objsb[j] = ""
				)
			)
		)
		append allSame_arr sameN_arr
		deleteItem objsb 1
	)
	-- output name list
	local delete_arr = #()
	for i in allSame_arr do
	(
		if i.count > 0 do
		(
			err+=1
			format "ͬ��Ϊ��%�����壬�ڳ�������%���� \n" i[1].name ((i.count+1) as String) to:mess
		)
		join delete_arr i
	)
	local delete_arr = makeUniqueArray delete_arr
	-- select and delete
	if delFlag do
	(
		select delete_arr
		delete delete_arr
	)
	-- create  error path and file
	if err >0 then
	(
		bSuc = false
		createLevelB 3 mess
	)
	if msgboxFlag do
	(
		if delete_arr.count > 0 then
		(
			messagebox"��������ģ���������ظ� ��鿴 plan\���� �ļ��У�"
			
		)else
		(
			messagebox"������û�������ظ������壬�������һ��������"
			
		)
	)
	
	enableSceneRedraw()
	
	logtimer "checkSameNobj() finish"
	
	return bSuc
)

/**
 * @brief check name rule
 */
fn checkMeshName delFlag msgboxFlag =
(
	local bSuc = true
	
	disableSceneRedraw()
	
	local mess = stringstream ""
	local mesherr = #()
	
	--��������mesh
	for iobj in  geometry do
	(
		if (nameruleChecker iobj.name) == false do
		(
			format "%\n" iobj.name to:mess
			append mesherr iobj
		)
	)
	
	if(mesherr.count) > 0 then
	(
		bSuc = false
		if delFlag == true do
		(
			delete mesherr
		)
		
		createLevelB 22 mess
		
		if msgboxFlag do
		(
			messagebox "mesh����������,��鿴 ���� �ļ��У�"
		)
	)

	enableSceneRedraw()
	
	logtimer "checkMeshName() finish"
	
	return bSuc
)

--- check mesh material and texture	
fn checkmattex delFlag =
(
	local bSuc = true
	
	disableSceneRedraw()
	
	local mess = "�����б���\n" 
	local i = 0
	local filename=""
	
	local mesherr = #()
	
	--��������mesh
	for iobj in  geometry do
	(
		errcount = 0
		
		if iobj.mat != undefined then
		(
			--��ȡ��ǰmesh�µ����в���
			mat = iobj.material
			submatnum = 0
			submatnum = getNumSubMtls mat
			if submatnum == 0 do
			(-- ����û���Ӳ���  -- ��Ϊ�����Ӳ��ʻ��п�����arch,������standard
				  
				if (classof mat) == standard then
				(-- ������standard
					
					if (classof mat.diffuseMap) == Bitmaptexture  then
					(-- ���Ͳ���Bitmaptexture��û����ͼ
						
						texname = mat.diffuseMap.filename
						if texname.count >=12 then
						(
							fnameCnt = (getfiles texname).count
							if fnameCnt != 0 then
							(
								texname_arr = filterstring texname "\\"
								cnt = texname_arr[texname_arr.count].count
								if cnt > 16 do
								(-- check texture name length
									i = i +1
									 message = stringStream ""
									 message = "A10�������壺" + (iobj.name) + "��ͼ���ֳ��ȴ���12���ַ�����Ҫ�Ķ̣�\n"
									 mess = mess + message
									 errcount = errcount + 1	
								)
							)else
							(-- �鿴�ļ��Ƿ����
								i = i +1
								 message = stringStream ""
								 message = "A11�������壺" + (iobj.name) + "û��diffuse��ͼ��\n"
								 mess = mess + message
								 errcount = errcount + 1
							)
						)else
						(-- ���filename����С��8��û����ͼ����Ϊ��С��"c:\a.jpg"���������8λ
							i = i +1
							 message = stringStream ""
							 message = "A11�������壺" + (iobj.name) + "û��diffuse��ͼ��\n"
							 mess = mess + message
							 errcount = errcount + 1
						)
					)else
					(
						i = i +1
						message = stringStream ""
						message = "A11�������壺" + (iobj.name) + "û��diffuse��ͼ��\n"
						mess = mess + message
						errcount = errcount + 1
					)
				)else
				(
					i = i +1
					message = stringStream ""
					message = "A8�������壺" + (iobj.name) + "�Ķ��������ǣ�" + ((classof mat)as string) + ", Ӧ����standard��\n"
					mess = mess + message
					errcount = errcount + 1
				)     
			)
			--������ǰ�����������Ӳ���
			if submatnum >0 do
			(-- ����û���Ӳ���  -- ��Ϊ���Ӳ��ʵĻ��п�����shellmat�Ĳ�����multimat
				
				if (classof mat) == Multimaterial then
				(-- ������multimat
					
					for im = 1 to submatnum do
					(
						if mat[im] != undefined then
						(-- ���Ӳ�����û�в���
							
							if (classof mat[im]) == standard then
							(
								if (classof mat[im].diffuseMap) == Bitmaptexture  then
								(-- ���Ͳ���Bitmaptexture��û����ͼ
									
									texname = mat[im].diffuseMap.filename
									if texname.count >=12 then
									(
										fnameCnt = (getfiles texname).count
										if fnameCnt != 0 then
										(
											texname_arr = filterstring texname "\\"
											cnt = texname_arr[texname_arr.count].count
											if cnt > 16 do
											(-- check texture name length
												i = i +1
												 message = stringStream ""
												 message = "A4�������壺" + (iobj.name) + "��ID��"+ (im as string) + "��ͼ���ֳ��ȴ���12���ַ�����Ҫ�Ķ̣�\n"
												 mess = mess + message
												 errcount = errcount + 1	
											)
										)else
										(-- �鿴�ļ��Ƿ����
											i = i +1
											 message = stringStream ""
											 message = "A12�������壺" + (iobj.name)+ "��ID��"+ (im as string) + "û��diffuse��ͼ��\n"
											 mess = mess + message
											 errcount = errcount + 1	
										)
									)else
									(-- ���filename����С��8��û����ͼ����Ϊ��С��"c:\a.jpg"���������8λ
										i = i +1
										message = stringStream ""
										message = "A12�������壺" + (iobj.name)+ "��ID��"+ (im as string) + "û��diffuse��ͼ��\n"
										mess = mess + message
										errcount = errcount + 1
									)
								)else
								(
									i = i +1
									message = stringStream ""
									message = "A12�������壺" + (iobj.name)+ "��ID��"+ (im as string)+ "û��diffuse��ͼ��\n"
									mess = mess + message
									errcount = errcount + 1
								)
							)else
							(
								i = i +1
								message = stringStream ""
								message = "A5�������壺" + (iobj.name)+ "��ID��"+ (im as string)+"�Ĳ����ǣ�" + ((classof mat[im])as string) + ", Ӧ����standard��\n"
								mess = mess + message
								errcount = errcount + 1
							)
						)else
						(
							continue
						)
					)
				)else
				(
					i = i +1
					message = stringStream ""
					message = "A6�������壺" + (iobj.name)+ "�Ķ�ά�����ǣ�"+ ((classof mat)as string) + "�� Ӧ����muitmaterial��\n"
					mess = mess + message
					
					errcount = errcount + 1
					
				)
			)
			
		)else
		(
			i = i +1
			message = stringStream ""
			message = "A7�������壺" + (iobj.name)+ "û�в��ʣ�\n"
			mess = mess + message
			errcount = errcount + 1
		)
		
		if errcount > 0 do
		(
			append mesherr iobj
		)
		
	 )
	
	if delFlag do
	(
		if(mesherr.count) > 0 do
		(
			delete mesherr
		) 
	)
	
	if mess.count >7 do ( i=i+1)
	if i > 0 then
	(
		bSuc = false
		createErrorLogFile "���ʺ���ͼ�����⡪����Ҫ�޸�.txt" mess
	)
	
	enableSceneRedraw()
	
	logtimer "checkmattex() finish"
	
	return bSuc
)

-- ��ѡ�е�ģ��ִ�н������
-- deleteFacesָʾ���ִ���ʱ,�Ƿ�ɾ����, ͨ���������ݹ�����һ����飬һ���޶�
fn checkMeshFace checkSelFlag deleteFaces delFlag msgboxFlag handle = 
(
	local bSuc = true
	
	disablesceneredraw()
	
	try(
		heatsize = 600000000-heapsize
	)catch()
	
	
	local mesherr = #()
	local count = 0;
	local longmessage = ""
	local longmessage1 = ""
	local message = ""
	local unweld = false
	local badface_arr = #{}
	local faceID_arr = #{}
	local faceID_i = 0
	
	-- ����ȫ��selection,���Ǻ�����Ҫѡ�����岢ִ��ɾ�������?
	local objset = #()
	
	if checkSelFlag then
	(
		if selection.count<=0 then
		(
			messagebox"��ѡ�����壡"
			return false
		)
		for o in selection do
		(
			append objset o
		)
	)
	else
	(
		for o in geometry do
		(
			append objset o
		)
	)
	
	for obj in objset do
	(
		nomatc = 0
		-- exclude non exported objects
		if ((classOf obj)==Dummy) then
		(
-- 			format "discard Dummy % \n" obj.name
			continue
		)
		
		-- ���mesh�Ǵ�������
		if ((classOf obj)==Box or (classOf obj)==Torus or (classOf obj)==Editable_poly or (classOf obj)==PolyMesh or (classOf obj)==PolyMeshObject) then
		(
			class = (classOf obj) as String
			if (deleteFaces==false) then
			(
				message2 = "Object " + obj.name + " is a "+class+", convert it to editable mesh\n"
--				print message2
				converttomesh obj
			) else (
				converttomesh obj
				message2 = "Object " + obj.name + " WAS "+class+", converted to editable mesh\n"
--				print message2
			)
		)

		if ((classOf obj)!=Editable_mesh) then
		(
--			format "discard %" obj.name
			continue
		)
		
--		format "analizying object % \n" obj.name

		if (obj.numfaces==0) then (
--			format "Object % has 0 faces! \n" obj.name
			longmessage = longmessage + obj.name + " has 0 faces!\n"
			nomatc = nomatc + 1
		)
		
		for i = 1 to obj.numfaces do 
		(
			if (i>obj.numfaces) then
				continue;

			face = getface obj i
			if (face==undefined) then
				continue;

			matID = getFaceMatID obj i
			if (obj.mat==undefined) then
			(
				longmessage1 = longmessage1 + "A7�������壺" + obj.name + " û�в���\n"
				--nomatc = nomatc + 1
			)
			else
			(
				if ((classOf obj.mat)!=Standardmaterial) then
				(
					if (obj.mat[matID]==undefined) then
					(
						longmessage1 = longmessage1 + "B2�������壺 " +obj.name+ " û��������� face " + (i as String) +"\n"
						nomatc = nomatc + 1
						append faceID_arr i
						faceID_i += 1 
						continue
					)
				)
			)
			
			v1 = getvert obj face[1]
			v2 = getvert obj face[2]
			v3 = getvert obj face[3]
			
			-- we had problems with rounding. some decimals are not shown, but present in the float
			-- the hacky solution is to convert to string. that truncates the decimals to 5
			v1x = v1.x as String
			v1y = v1.y as String
			v1z = v1.z as String
			v2x = v2.x as String
			v2y = v2.y as String
			v2z = v2.z as String
			v3x = v3.x as String
			v3y = v3.y as String
			v3z = v3.z as String

			--format "% % % % \n" obj.name v1 v2 v3
			
			bad = 0;
			equal = 0;
			
			-- check for 2 vertexes in the same spot
			vflag1 = (v1x==v2x and v1y==v2y and v1z==v2z)
			vflag2 = (v1x==v3x and v1y==v3y and v1z==v3z)
			vflag3 = (v2x==v3x and v2y==v3y and v2z==v3z)
			vflag4 = vflag1 or vflag2 or vflag3
			
			if(vflag4 == true) then
			(
				bad = 1;

			)
			else
			(	-- check for at least 2 axis are equal on all tree vertexes
				if (v1x==v2x and v2x==v3x) then
					equal = equal + 1;
				if (v1y==v2y and v2y==v3y) then
					equal = equal + 1;
				if (v1z==v2z and v2z==v3z) then
					equal = equal + 1;
				if (equal>1) then
					bad = 1;
			)
			
			if (bad==1) then
			(
				logtimer ("find bad face : "+obj.name)
-- 				format "The object % has an INVALID polygon: %\n" obj.name face
				longmessage = longmessage + "B1����ģ�ͣ�" +obj.name + " ��" +(face as String)+":id="+(i as String)+"���Ǹ����棡, �䶨������Ϊ: " + "[" + v1x + "," + v1y + "," + v1z + "]"+ "[" + v2x + "," + v2y + "," + v2z + "]"+ "[" + v3x + "," + v3y + "," + v3z + "]"+ "\n"
				count = count + 1;
				nomatc = nomatc + 1

				append badface_arr i

				-- delete the polygon
				if (deleteFaces==true) then (
					logtimer ( (format "deleting % face %\n" obj.name i) as string )
					select obj
					subObjectLevel = 3 -- set subobjectlevel to triangle
					delete obj.faces[i]
				)
			)
			
		) -- end for numfaces
-- 			print badface_arr.count
		if ((badface_arr.count>0) or (faceID_arr.count >0)) do
		(
			if handle == "select" do
			(
				select obj
				exit
			)
		)

		if nomatc > 0 do
		(
			append mesherr obj
			--messagebox (obj.name)
		)

		/*verts = getNumVerts obj
		uvVerts = getNumTVerts obj
		format "% % \n" verts uvVerts
		if (uvVerts>verts) then (
		  if (unweld==false) then (
			unweld=true
			longmessage = longmessage + "�кܶ�δ�ϲ���uv���������������: "+obj.name
		  ) else (
			longmessage = longmessage + ", " +obj.name
		  )
		)*/
	)

	if checkSelFlag then
	(
		if selection.count == 1 then
		(
			if (badface_arr.count>0)do
			(-- ѡ��face
	-- 				converttopoly obj
				max modify mode
				subObjectLevel = 3 
				setFaceSelection $ badface_arr
				badSel = getfaceselection $
	-- 				format "%\n" badSel
			)
			if (faceID_arr.count >0)do
			(-- ѡ��face
	-- 				converttopoly obj
				max modify mode
				subObjectLevel = 3 
				setFaceSelection $ faceID_arr
				idSel = getfaceselection $
	-- 				format "%\n" idSel
			)
				
			if badface_arr.count == 0 and faceID_arr.count == 0  then
			(
				messagebox"������������"
				setFaceSelection $ #{}
			)
			else if badface_arr.count > 0 then
			(messagebox"�����廹�л��棬�봦����")
			else if faceID_arr.count > 0 then
			(messagebox"��������Щ��û�ж�����ʣ��봦����")
			
		)
	)

	
-- 		format "Total bad polygons: % " count;

	cs = count as String
	if (deleteFaces) then
		(message = "Total bad polygons found and deleted: " + cs)
	else
		(message = "���л��汻�ҵ�: " + cs)
	
	message = message + "\n" + (longmessage1 as String) + (longmessage as String)
	--messageBox message
	
	if (mesherr.count) > 0 then
	(
		bSuc = false
		createErrorLogFile "ģ�������⡪����Ҫ�޸�.txt" message
		
		if delFlag do
		(
			for iobj in mesherr do
			(
				--select iobj
				delete iobj
				--print (iobj.name)
			)
		)
	)
	
	enablesceneredraw()
	
	logtimer "checkMeshFace() finish"
	
	if msgboxFlag do
	(
		messagebox"����ģ�ͼ����ϣ���鿴 plan\����  �ļ��У�"
	)
	
	return bSuc
)

--���ÿ��ģ���ϵ�����
fn checkFaceNum delFlag msgboxFlag =
(
	local bSuc = true
	
	disablesceneredraw()
	
	local mess = stringstream ""
	local delete_arr = #()
	
	for i in geometry do
	(
		try(
			converttomesh i
			faceNum = meshop.getNumFaces i
			if faceNum > 50000 do
			(
				format "ģ��:%  �������ǣ�%������50000�������棬��Ҫ���棬���߲�ɢ���壡 \n" i.name (faceNum as string) to:mess
				append delete_arr i
			)
		)catch()
	)
	
	if delete_arr.count > 0 then
	(
		bSuc = false
		createLevelB 4 mess
		
		if delFlag do
		(
			delete delete_arr
		)
		
		if msgboxFlag do
		(
			messagebox "�������г���5w���ģ�ͣ���鿴plan\���� �ļ��У���5w��Ϊ���ޣ�detach����ģ�ͣ���Ҫ̫�飡"
		)
	)
	
	enablesceneredraw()
	
	logtimer "checkFaceNum() finish"
	
	return bSuc
)

--�����ͼ���Ƿ񳬹�660
fn ChkTexMapNums =
(
	local bSuc = true
	
	disablesceneredraw()
	
	local arrMap = #()
	
	for iobj in geometry do
	(
		local curmat = iobj.mat
		if(classof curmat == Standardmaterial) then
		(
			if((curmat.diffuseMap) != undefined) and (classof(curmat.diffuseMap)) == Bitmaptexture then
			(
				texname = curmat.diffuseMap.filename
				appendIfUnique arrMap texname
			)
		)
		else if((classof curmat) == multimaterial ) then
		(
			 for submatid = 1 to curmat.materialList.count do
			 (
				CurrentSubMtl = curmat.materialList[submatid]
				if(CurrentSubMtl != undefined) and (classof CurrentSubMtl)  == Standardmaterial then --��ά�����п��ܳ���ĳidδ��������
				(
					--print iobj.name
					if (CurrentSubMtl.diffuseMap) != undefined  and (classof(CurrentSubMtl.diffuseMap)) == Bitmaptexture then
					(
						texname = CurrentSubMtl.diffuseMap.filename
						appendIfUnique arrMap texname
					)
				)
			)
		)
	)
	
	if(arrMap.count > 900) then
	(
		bSuc = false
		createLevelB 9 ""
	)
	
	enableSceneRedraw()
	
	logtimer "ChkTexMapNums() finish"
	
	return bSuc
)

--��鳡���������Ƿ񳬹�33��
fn ChkSceneFaceNums =
(
	local bSuc = true
	
	disableSceneRedraw()
	
	local arrXiaopin = selectMeshgen()
	Xpnum = 0
	try(
		if( arrXiaopin.count > 0)then
		(
			for iobj in arrXiaopin do
				Xpnum += iobj.numfaces
		)
	)catch()	
	local arrGndmesh = for i in geometry where matchPattern i.name pattern:("gnd*") ignoreCase:false collect i
	terriannum = 0
	try(
		for ignd in arrGndmesh do
			terriannum += ignd.numfaces
	)catch()	
	jznum = 0
	for iobj in geometry do
	(
		if(finditem arrXiaopin iobj) != 0 then continue
		if(matchPattern iobj.name pattern:("gnd*") ignoreCase:false) == true then continue
		if(matchPattern iobj.name pattern:("sky*") ignoreCase:false) == true then continue
		if(matchPattern iobj.name pattern:("plant*") ignoreCase:false) == true then continue
		try(
			jznum += iobj.numfaces	
		)catch()	
	)
	
	logtimer "������Ϣ�� "
	logtimer (" 1��������������Ϊ��" + (jznum as string))
	logtimer (" 2��СƷ������Ϊ��" + (Xpnum as string))
	logtimer (" 3������������Ϊ��" + (terriannum as string))
	
	if(jznum > 330000) do
	(
		bSuc = false
		createLevelB 8 ""
	)
	
	enableSceneRedraw()
	
	logtimer "ChkSceneFaceNums() finish"
	
	return bSuc
)

-- *********************************************************************
-- *********************************************************************
--
--                              check 2
--
-- *********************************************************************
-- *********************************************************************

fn ChkTexture =
(
	-- �Ѷ�png͸����飬��ͼ�ߴ磬��С���������жϷ�������
	local pp = getProjectPath()
	if pp == false then
	(
		return 0
	)
	
	-- dp��һ��txt�ļ��ľ��Ե�ַ
	-- ���txt�ļ������˸ó���������ģ��ʹ�õ���ͼ�ľ���·����
	local dp = exptexInfo()
	if dp == "" then return 0
	
	-- ���png͸��ͨ��
	local param =  " --str="+ dp + " "
	param += " --log=" + (pp + "\\plan\\����\\" + G_LevelAError[14] + ".txt") + " "
	startSppTool "check_png_alpha" param
	
	-- �����ͼ�Ƿ���Ϲ淶
	param =  " --dir=\""+ dp + "\" "
	param += " --log=\"" + (pp + "\\plan\\����\\" + G_LevelAError[15] + ".txt") + "\" "
	startSppTool "checkTexture" param
)